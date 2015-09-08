module ApiCalls extend ActiveSupport::Concern
 
  WEEK_NUMBERS = [23, 24, 25, 26]

  included do
    before_action :get_employees, only: [:index]
    before_action :get_rule_definitions, only: [:index]
    before_action :get_shift_rules, only: [:index]
    before_action :get_date_range, only: [:index]
  end

  #
  # Base URL class variable and helper method for access in the view
  #
  @@domain = 'http://interviewtest.replicon.com'
#  helper_method :domain
  def domain
    @@domain
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
