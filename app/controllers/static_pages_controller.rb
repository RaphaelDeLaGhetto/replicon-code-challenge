class StaticPagesController < ApplicationController
#  skip_authorization_check :only => [:home]
#  authorize_resource :class => false

  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def apps
    authorize! :apps, :static_page
  end
end
