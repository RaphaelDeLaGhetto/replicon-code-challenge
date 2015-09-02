class EmployeesController < ApplicationController
  before_filter do
    authorize! :manage, :employee
  end
  before_action :schedule, only: [:index]

  DOMAIN = 'http://interviewtest.replicon.com'
  WEEK_NUMBERS = [23, 24, 25, 26]

  #
  # index
  #
  def index
  end

  #
  # show
  #
  def show
  end

  private

    #
    # schedule
    #
    def schedule
      get_employees
      get_rule_definitions
      get_shift_rules
      get_date_range

      return if @employees.nil? || @shift_rules.nil? || @rule_definitions.nil? || @start_date.nil?

      # Ad hoc June scheduling
      # TODO: add date picker to make this more robust
      

    end

    #
    # get_employees
    #
    def get_employees
      response = HTTParty.get("#{DOMAIN}/employees")
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
      response = HTTParty.get("#{DOMAIN}/shift-rules")
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
      response = HTTParty.get("#{DOMAIN}/rule-definitions")
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
      response = HTTParty.get("#{DOMAIN}/weeks/#{WEEK_NUMBERS[0]}")
      case response.code
        when 200
          @start_date = Date.parse(JSON.parse(response.body)['start_date'])
        else
          flash[:error] = "The start date could not be retrieved: #{response.code}"
      end

      response = HTTParty.get("#{DOMAIN}/weeks/#{WEEK_NUMBERS.last}")
      case response.code
        when 200
          # Adding six takes us to the last day before the new week
          @end_date = Date.parse(JSON.parse(response.body)['start_date']) + 6
        else
          flash[:error] = "The end date could not be retrieved: #{response.code}"
      end
    end
end
