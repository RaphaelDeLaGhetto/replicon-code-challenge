module Scheduler extend ActiveSupport::Concern

  WEEK_NUMBERS = [23, 24, 25, 26]

  included do
    before_action :schedule, only: [:index]
  end

  #
  # schedule
  #
  def schedule
    return if @employees.nil? ||
              @shift_rules.nil? ||
              @rule_definitions.nil? ||
              @start_date.nil? ||
              @timeoff.nil?


    available_spec = ScheduleSpecification::IsAvailable.new(@employees, @timeoff)

    # Ad hoc June scheduling
    # TODO: add date picker to make this more robust
    
    # Apply the EMPLOYEES_PER_SHIFT rule
    employees_per_shift = nil
    @rule_definitions.each do |definition|
      id = definition['id'] if definition['value'] == 'EMPLOYEES_PER_SHIFT'
      if id
        @shift_rules.each do |rule|
          employees_per_shift = rule['value'] if id == rule['rule_id']
          break if employees_per_shift
        end
        break
      end
    end

    # Create the schedule
    @schedule = []
    day_index = 0
    week_index = -1

    # Create calendar events
    @events = []
    employee_index = 0

    (@start_date..@end_date).each do |day|
      # Schedule data
      if day_index % 7 == 0
        week_index += 1
        day_index = 0
        @schedule << { week: WEEK_NUMBERS[week_index], schedules: [] }
      end
      day_index += 1

      #
      # Build the schedule and the calendar events
      #

      # Keep track of schedule employees so that no one gets double booked
      scheduled_employees = []

      # If the number of attempts at scheduling exceeds available employees,
      # rules and time off requests are ignored
      tries = 0
      force_schedule = false

      while scheduled_employees.count < employees_per_shift do
        if force_schedule ||
           (tries < @employees.count &&
           available_spec.is_satisfied_by?({ employee_id: @employees[employee_index]['id'],
                                             week: WEEK_NUMBERS[week_index],
                                             day: day_index }))

          # If this condition is true, all employees have been considered for a shift
          # twice and no one was found. This stops the loop from trying forever.
          break if tries >= @employees.count * 2
          tries += 1

          # Skip if this employee is already scheduled to work
          next if scheduled_employees.include?(@employees[employee_index]['id'])
          scheduled_employees << @employees[employee_index]['id']

          # Calendar events
          name = @employees[employee_index]['name']
          @events << { title: name, id: name.gsub(/[^0-9A-Za-z]/, ''), start: day.to_formatted_s(:db) }
  
          # Get index of employee's schedule for this week
          schedule_index = nil
          @schedule[week_index][:schedules].each_with_index do |schedule, i|
            if schedule[:employee_id] == @employees[employee_index]['id']
              schedule_index = i
              break
            end
          end
  
          # Insert day into employee's schedule
          if schedule_index
            @schedule[week_index][:schedules][schedule_index][:schedule] << day_index
          else
            @schedule[week_index][:schedules] << { employee_id: @employees[employee_index]['id'], schedule: [day_index] }
          end
        else
          force_schedule = true
        end

        # Point to the next employee in line
        employee_index = (employee_index + 1) % @employees.count
      end
    end
  end
end
