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

#  before_action :authenticate_agent!, only: [:index, :show, :edit, :update, :destroy]
#  before_action :set_agent, only: [:show, :edit, :update, :destroy]
#  before_action only: [:edit, :update] do
#    correct_agent @agent 
#  end
#  before_action :admin_agent, only: [:destroy]
#
#  #
#  # index
#  #
#  def index
#    @agents = Agent.paginate(page: params[:page])
#  end
#
#  #
#  # show
#  #
#  def show
#    @agent = Agent.find(params[:id])
#  end
#
#  #
#  # new
#  #
##  def new
##    @agent = Agent.new
##  end
#
#  #
#  # create
#  #
##  def create
##    message = "Please check your email to activate your account."
##    if admin_logged_in?
##      message = "An activation email has been sent to the new agent."
##    elsif agent_params[:admin]
##      flash[:danger] = 'You cannot create an admin agent'
##      redirect_to new_agent_path
##      return
##    end
##
##    @agent = Agent.new(agent_params)
##    if @agent.save
##      @agent.send_activation_email
##      flash[:info] = message
##      redirect_to root_url
##    else
##      render 'new'
##    end
##  end
#
#  #
#  # edit
#  #
#  def edit
#  end
#
#  #
#  # destroy
#  #
#  def destroy
#    Agent.find(params[:id]).destroy
#    flash[:success] = "Agent deleted"
#    redirect_to agents_url
#  end
#
  private

    def agent_params
      params.require(:agent).permit(:name, :email, :password, :password_confirmation, :admin)
    end

    def set_agent
      @agent = Agent.find(params[:id])
    end
end
