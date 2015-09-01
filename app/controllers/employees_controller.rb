class EmployeesController < ApplicationController
#  before_filter(:only => [:index, :show]) { authorize! if cannot? :read, :calendar }
  before_filter do
    authorize! :manage, :employee
  end
#  load_and_authorize_resource

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
