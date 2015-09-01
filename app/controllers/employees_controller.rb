class EmployeesController < ApplicationController
  before_filter do
    authorize! :manage, :employee
  end

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
end
