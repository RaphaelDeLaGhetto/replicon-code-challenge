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

    # Fire up the specifications
    available_spec = ScheduleSpecification::IsAvailable.new(@schedule, @employees, @timeoff, @shift_rules, @rule_definitions)
    needs_more_shifts_spec = ScheduleSpecification::NeedsMoreShifts.new(@schedule, @shift_rules, @rule_definitions)
    already_scheduled_spec = ScheduleSpecification::AlreadyScheduled.new(@schedule, @employees)
    requested_timeoff_spec = ScheduleSpecification::RequestedTimeoff.new(@timeoff)
    exceeds_max_shifts_spec = ScheduleSpecification::ExceedsMaxShifts.new(@schedule, @shift_rules, @rule_definitions)

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

      # Count the number of schedule employees so the EMPLOYEES_PER_SHIFT
      # rule can be enforced
      scheduled_employees = 0 

      # If the number of attempts at scheduling exceeds available employees,
      # rules and time off requests are ignored
      tries = 0
      force_schedule = false

      # Go until every open shift has been filled
      while scheduled_employees < employees_per_shift do

        #
        # If an available employee hasn't turned up on the first pass, make one
        # last-ditch effort to respect time off requests
        #
        if (force_schedule)
          @employees.each_with_index do |employee, index|
            subject = { employee_id: employee['id'],
                        week: WEEK_NUMBERS[week_index],
                        day: day_index }
            if !already_scheduled_spec.is_satisfied_by?(subject) &&
               !requested_timeoff_spec.is_satisfied_by?(subject) &&
               !exceeds_max_shifts_spec.is_satisfied_by?(subject)
              employee_index = index
              break
            end
          end
        end

        # The subject used in satisfying the schedule specifications
        subject = { employee_id: @employees[employee_index]['id'],
                    week: WEEK_NUMBERS[week_index],
                    day: day_index }

        if (force_schedule &&
            !already_scheduled_spec.is_satisfied_by?(subject) &&
            !exceeds_max_shifts_spec.is_satisfied_by?(subject)) ||
           available_spec.is_satisfied_by?(subject)

          scheduled_employees += 1

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
        end

        # Ignore rules and pick the next person in the queue if no employee is found for a shift
        tries += 1
        force_schedule = tries >= @employees.count
        break if tries >= @employees.count * 2
        
        # If an employee has not received his shift quota, keep skipping ahead until enough 
        # shifts have been scheduled (unless time off was requested)
        next_index = (employee_index + 1) % @employees.count
        if needs_more_shifts_spec.is_satisfied_by?(subject) &&
           !requested_timeoff_spec.is_satisfied_by?(subject)
            
          @employees[employee_index], @employees[(next_index+1) % @employees.count] =
                @employees[(next_index+1) % @employees.count], @employees[employee_index]
        end

        # Point to the next employee in line
        employee_index = next_index
      end
    end
  end
end
