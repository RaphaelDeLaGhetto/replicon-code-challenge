class EmployeesController < ApplicationController
  before_filter do
    authorize! :manage, :employee
  end

  #
  # index
  #
  def index
    response = HTTParty.get('http://interviewtest.replicon.com/employees')
    case response.code
      when 200
        @employees = JSON.parse(response.body)
      else
        flash[:error] = "The API cannot be reached: #{response.code}"
    end
  end

  #
  # show
  #
  def show
  end
end
