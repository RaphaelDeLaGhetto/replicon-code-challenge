class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
#  include DeviseHelper

  #
  # cancancan
  #
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    if agent_signed_in?
      redirect_to root_url
    else
      # This would normally get saved by Devise automatically on
      # login failure. I set it here manually because CanCan
      # is thrown into the mix.
      store_location_for(:agent, request.url)
      redirect_to login_url
    end
  end

  # Alias cancancan's `current_user` method 
  alias_method :current_user, :current_agent

  private

    #
    # For friendly forwarding with Devise
    # This doesn't work out of the box. I need to manually
    # set the agent_return_to key because of CanCan
    # getting in the way.
    # 2015-8-28 https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update#a-simpler-solution
    #
    def after_sign_in_path_for(resource)
      session['agent_return_to'] || root_url
    end
end
