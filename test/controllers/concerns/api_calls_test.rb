require 'test_helper'

class ApiDummyController < ApplicationController
  include ApiCalls
  def index
  end
end

class ApiDummyControllerTest < ActionController::TestCase
  tests ApiDummyController

  def setup
    @routes = MyEngine::Engine.routes
    mock_api
  end

  #
  # start_date and end_date
  #
  test "should set the start_date and end_date instance variables" do
    get :index
    assert_response :success

    # This is hardcoded to start in June, for now
    assert_equal Date.new(2015, 06, 01), assigns(:start_date)
    assert_equal Date.new(2015, 06, 28), assigns(:end_date)
  end

  #
  # employees
  #
  test "should set the employees instance variable" do
    get :index
    assert_not_nil assigns(:employees)
    assert_response :success

    employees = assigns(:employees)
    assert_equal 5, employees.count

    employees.each do |employee|
      case employee['id']
      when 1
        assert_equal 'Lanny McDonald', employee['name']
      when 2
        assert_equal 'Allen Pitts', employee['name']
      when 3
        assert_equal 'Gary Roberts', employee['name']
      when 4
        assert_equal 'Dave Sapunjis', employee['name']
      when 5
        assert_equal 'Mike Vernon', employee['name']
      end
    end
  end

  test "should set an error message if app can't get employee list" do
    stub_request(:get, "#{DOMAIN}/employees").
        to_return(:body => 'Some crazy error message', :status => 500)

    get :index
    assert_nil assigns(:employees)
    assert_response :success

    assert_equal 'The employee list could not be retrieved: 500', flash[:error]
  end

  #
  # shift_rules
  #
  test "should set the shift_rules instance variable" do
    get :index
    assert_not_nil assigns(:shift_rules)
    assert_response :success

    shift_rules = assigns(:shift_rules)
    assert_equal 7, shift_rules.count

    assert_equal 1, shift_rules[0]['employee_id']
    assert_equal 4, shift_rules[0]['rule_id']
    assert_equal 3, shift_rules[0]['value']
    assert_nil shift_rules[6]['employee_id']
    assert_equal 7, shift_rules[6]['rule_id']
    assert_equal 2, shift_rules[6]['value']
  end

  test "should set an error message if app can't get shift_rules list" do
    stub_request(:get, "#{DOMAIN}/shift-rules").
        to_return(:body => 'Some crazy error message', :status => 500)

    get :index
    assert_nil assigns(:shift_rules)
    assert_response :success

    assert_equal 'The shift rules could not be retrieved: 500', flash[:error]
  end

  #
  # rule_definitions
  #
  test "should set the rule_definitions instance variable" do
    get :index
    assert_not_nil assigns(:rule_definitions)
    assert_response :success

    rule_definitions = assigns(:rule_definitions)
    assert_equal 3, rule_definitions.count

    assert_equal 'Minimum number of shifts an employee must work per week. If employee_id is included then this applies to that employee only.',
        rule_definitions[0]['description']
    assert_equal 4, rule_definitions[0]['id']
    assert_equal 'MIN_SHIFTS', rule_definitions[0]['value']
    assert_equal 'Number of employees required per shift',
        rule_definitions[2]['description']
    assert_equal 7, rule_definitions[2]['id']
    assert_equal 'EMPLOYEES_PER_SHIFT', rule_definitions[2]['value']
  end

  test "should set an error message if app can't get rule_definitions list" do
    stub_request(:get, "#{DOMAIN}/rule-definitions").
        to_return(:body => 'Some crazy error message', :status => 500)

    get :index
    assert_nil assigns(:rule_definitions)
    assert_response :success

    assert_equal 'The rule definitions could not be retrieved: 500', flash[:error]
  end

  #
  # timeoff
  #
  test "should set the timeoff instance variable" do
    get :index
    assert_not_nil assigns(:timeoff)
    assert_response :success

    timeoff = assigns(:timeoff)
    assert_equal 14, timeoff.count

    assert_equal [1, 2, 3], timeoff[0]['days']
    assert_equal 1, timeoff[0]['employee_id']
    assert_equal 23, timeoff[0]['week']

    assert_equal [1], timeoff.last['days']
    assert_equal 2, timeoff.last['employee_id']
    assert_equal 26, timeoff.last['week']
  end

  test "should set an error message if app can't get timeoff list" do
    stub_request(:get, "#{DOMAIN}/time-off/requests").
        to_return(:body => 'Some crazy error message', :status => 500)

    get :index
    assert_nil assigns(:timeoff)
    assert_response :success

    assert_equal 'The timeoff details could not be retrieved: 500', flash[:error]
  end
end
