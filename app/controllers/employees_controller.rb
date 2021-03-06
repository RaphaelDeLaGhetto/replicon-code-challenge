class EmployeesController < ApplicationController
  include ScheduleSpecification
  include ApiCalls
  include Scheduler

  before_filter do
    authorize! :manage, :employee
  end

  #
  # Base URL class variable and helper method for access in the view
  #
  helper_method :domain
  def domain
    domain
  end

  #
  # index
  #
  def index
  end

  #
  # submit
  #
  def submit
    query = { name: 'Daniel Bidulock', email: 'daniel@bidulock.ca', features: [1, 2, 3, 4, 5, 6] }

    # For real submission
    query[:solution] = true if params[:employee][:solution] == '1'

    if query[:solution] && !admin_logged_in?
      flash[:error] = 'Only an administrator can submit for real'
      return redirect_to root_path 
    end

    @response = HTTParty.post("#{@@domain}/submit", 
      :body => params[:employee][:schedule],
      :query => query,
      :headers => { 'Content-Type' => 'application/json' } )
    @response = @response.parsed_response
  end
end
