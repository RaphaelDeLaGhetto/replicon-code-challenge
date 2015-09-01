class Agents::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication, only: [:create]
  before_filter :configure_sign_up_params, only: [:create]

  # POST /resource
  def create
    if admin_logged_in?
      @agent = Agent.new(sign_up_params)
      if @agent.save
        flash[:info] = "An activation email has been sent to the new agent"
        redirect_to agents_url
      else
        render 'new'
      end
    elsif params[:agent][:admin]
      flash[:danger] = 'You cannot create an admin agent'
      redirect_to root_path
    else
      super
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :name << :admin
  end
end
