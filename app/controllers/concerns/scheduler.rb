module Scheduler extend ActiveSupport::Concern

  WEEK_NUMBERS = [23, 24, 25, 26]

  included do
    before_action :schedule, only: [:index]
  end

  #
  # schedule
  #
  def schedule
    return if @employees.nil? || @shift_rules.nil? || @rule_definitions.nil? || @start_date.nil?

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

      # Calendar events
      employees_per_shift.times do |i|
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

        # Point to the next employee in line
        employee_index = (employee_index + 1) % @employees.count
      end
    end
  end
end
