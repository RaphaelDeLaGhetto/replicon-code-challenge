# 2015-8-27
# https://github.com/plataformatec/devise/wiki/How-To:-Manage-Users-with-an-Admin-Role-(CanCan-method)
class AgentsController < ApplicationController
  load_and_authorize_resource
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  #
  # index
  #
  def index
    @agents = Agent.paginate(page: params[:page])
  end

  #
  # new
  #
  def new
    @agent = Agent.new
  end

  #
  # edit
  #
  def edit
  end

  #
  # show
  #
  def show
  end

  #
  # update
  #
  def update
    update_params = agent_params
    update_params.delete(:password) if update_params[:password].blank?
    update_params.delete(:password_confirmation) if update_params[:password].blank? and update_params[:password_confirmation].blank?
    if @agent.update_attributes(admin_logged_in? ? update_params : update_params.except(:admin))
      flash[:notice] = "Successfully updated Agent."
      redirect_to @agent
    else
      flash[:error] = @agent.errors
      render :action => 'edit'
    end
  end

  #
  # destroy
  #
  def destroy
    if @agent.destroy
      flash[:notice] = "Successfully deleted Agent."
      redirect_to agents_path
    end
  end 

  private

    def agent_params
      params.require(:agent).permit(:name, :email, :password, :password_confirmation, :admin)
    end

    def set_agent
      @agent = Agent.find(params[:id])
    end
end
