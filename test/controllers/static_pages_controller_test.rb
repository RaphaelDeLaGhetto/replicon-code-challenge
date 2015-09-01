require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  #
  # home
  #
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "#{ENV['app_title']}"
  end

  #
  # apps
  #
  test "should redirect get apps if not logged in" do
    get :apps
    assert_redirected_to login_url 
  end

  test "should get apps if logged in as non-admin" do
    sign_in agents(:archer)
    get :apps
    assert_response :success
    assert_select "title", "Apps | #{ENV['app_title']}"
  end

  test "should get apps if logged in as admin" do
    sign_in agents(:daniel)
    get :apps
    assert_response :success
    assert_select "title", "Apps | #{ENV['app_title']}"
  end
end
