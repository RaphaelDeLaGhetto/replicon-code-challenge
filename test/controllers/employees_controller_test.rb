require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase

  def setup
    @admin = agents(:daniel)
    @agent = agents(:archer)
  end

  #
  # index
  #
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end


#  test "should get index" do
#    get :index
#    assert_response :success
#  end

  #
  # show
  #
#  test "should get show" do
#    get :show
#    assert_response :success
#  end

  #
  # show
  #
  test "should redirect show when not logged in" do
    get :show, id: @agent
    assert_redirected_to login_url
  end

  test "should show when logged in" do
    sign_in(@agent)
    get :show, id: @agent
    assert_response :success
  end


end
