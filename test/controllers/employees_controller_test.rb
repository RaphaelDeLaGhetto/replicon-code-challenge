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

  test "should set the employees instance variable when logged in" do
    stub_request(:get, 'http://interviewtest.replicon.com/employees').
        to_return(:body => File.new('test/json/employees.json'), :status => 200)

    sign_in(@agent)
    get :index
    assert_not_nil assigns(:employees)
    assert_response :success

    employees = assigns(:employees)
    assert_equal 5, employees.count

    assert_equal 'Lanny McDonald', employees[0]['name']
    assert_equal 1, employees[0]['id']
    assert_equal 'Mike Vernon', employees[4]['name']
    assert_equal 5, employees[4]['id']
  end

  test "should set an error message if app can't connect to API" do
    stub_request(:get, 'http://interviewtest.replicon.com/employees').
        to_return(:body => 'Some crazy error message', :status => 500)

    sign_in(@agent)
    get :index
    assert_nil assigns(:employees)
    assert_response :success

    assert_equal 'The API cannot be reached: 500', flash[:error]
  end


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
