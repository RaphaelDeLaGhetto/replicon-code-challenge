class EmployeesController < ApplicationController
  before_filter do
    authorize! :manage, :employee
  end
  before_action :get_employees, only: [:index]
  before_action :get_rule_definitions, only: [:index]
  before_action :get_shift_rules, only: [:index]
  before_action :get_date_range, only: [:index]
  before_action :schedule, only: [:index]

  #
  # Base URL class variable and helper method for access in the view
  #
  @@domain = 'http://interviewtest.replicon.com'
  helper_method :domain
  def domain
    @@domain
  end

  WEEK_NUMBERS = [23, 24, 25, 26]

  #
  # index
  #
  def index
  end

  #
  # submit
  #
  def submit
    @response = HTTParty.post("#{@@domain}/submit", 
      :body => params[:employee][:schedule],
      :headers => { 'Content-Type' => 'application/json' } )
    @response = @response.parsed_response
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(:schedule)
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

    #
    # get_employees
    #
    def get_employees
      response = HTTParty.get("#{@@domain}/employees")
      case response.code
        when 200
          @employees = JSON.parse(response.body)
        else
          flash[:error] = "The employee list could not be retrieved: #{response.code}"
      end
    end

    #
    # get_shift_rules
    #
    def get_shift_rules
      response = HTTParty.get("#{@@domain}/shift-rules")
      case response.code
        when 200
          @shift_rules = JSON.parse(response.body)
        else
          flash[:error] = "The shift rules could not be retrieved: #{response.code}"
      end
    end

    #
    # get_rule_definitions
    #
    def get_rule_definitions
      response = HTTParty.get("#{@@domain}/rule-definitions")
      case response.code
        when 200
          @rule_definitions = JSON.parse(response.body)
        else
          flash[:error] = "The rule definitions could not be retrieved: #{response.code}"
      end
    end

    #
    # get_date_range
    #
    # This is hard-coded to start in June, for now
    #
    def get_date_range
      response = HTTParty.get("#{@@domain}/weeks/#{WEEK_NUMBERS[0]}")
      case response.code
        when 200
          @start_date = Date.parse(JSON.parse(response.body)['start_date'])
        else
          flash[:error] = "The start date could not be retrieved: #{response.code}"
      end

      response = HTTParty.get("#{@@domain}/weeks/#{WEEK_NUMBERS.last}")
      case response.code
        when 200
          # Adding six takes us to the last day before the new week
          @end_date = Date.parse(JSON.parse(response.body)['start_date']) + 6
        else
          flash[:error] = "The end date could not be retrieved: #{response.code}"
      end
    end
end
