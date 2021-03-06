require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  should use_before_action :get_employees
  should use_before_action :get_rule_definitions
  should use_before_action :get_shift_rules
  should use_before_action :get_date_range
  should use_before_action :get_timeoff
  should use_before_action :schedule

  def setup
    @admin = agents(:daniel)
    @agent = agents(:archer)

    mock_api
  end

  def teardown
    WebMock.reset!
  end

  #
  # index
  #
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should set the start_date and end_date instance variables when logged in" do
    sign_in(@agent)
    get :index
    assert_response :success

    # This is hardcoded to start in June, for now
    assert_equal Date.new(2015, 06, 01), assigns(:start_date)
    assert_equal Date.new(2015, 06, 28), assigns(:end_date)
  end

  test "should set the employees instance variable when logged in" do
    sign_in(@agent)
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

    sign_in(@agent)
    get :index
    assert_nil assigns(:employees)
    assert_response :success

    assert_equal 'The employee list could not be retrieved: 500', flash[:error]
  end

  test "should set the shift_rules instance variable when logged in" do
    sign_in(@agent)
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

    sign_in(@agent)
    get :index
    assert_nil assigns(:shift_rules)
    assert_response :success

    assert_equal 'The shift rules could not be retrieved: 500', flash[:error]
  end

  test "should set the rule_definitions instance variable when logged in" do
    sign_in(@agent)
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

    sign_in(@agent)
    get :index
    assert_nil assigns(:rule_definitions)
    assert_response :success

    assert_equal 'The rule definitions could not be retrieved: 500', flash[:error]
  end

  test "should set the events instance variable when logged in" do
    sign_in(@agent)
    get :index
    assert_response :success

    events = assigns(:events)
    assert_not_nil events

    # 4 weeks x 7 days x 2 employees per day
    assert_equal 4*7*2, events.count

    assert_equal '2015-06-01', events[0][:start]

    assert_equal events[-1][:id], events[-1][:title].gsub(/[^0-9A-Za-z]/, '')
    assert_equal '2015-06-28', events[-1][:start]
  end

  test "should set the schedule instance variable when logged in" do
    sign_in(@agent)
    get :index
    assert_response :success

    schedule = assigns(:schedule)
    assert_not_nil schedule

    assert_equal 4, schedule.count

    # Week 23
    assert_equal 23, schedule[0][:week]
    assert_equal 5, schedule[0][:schedules].count

    # Week 24
    assert_equal 24, schedule[1][:week]
    assert_equal 5, schedule[1][:schedules].count

    # Week 25
    assert_equal 25, schedule[2][:week]
    assert_equal 5, schedule[2][:schedules].count

    # Week 26
    assert_equal 26, schedule[3][:week]
    assert_equal 5, schedule[3][:schedules].count
  end

  #
  # timeoff
  #
  test "should set the timeoff instance variable when logged in" do
    sign_in(@agent)
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

    sign_in(@agent)
    get :index
    assert_nil assigns(:timeoff)
    assert_response :success

    assert_equal 'The timeoff details could not be retrieved: 500', flash[:error]
  end

  #
  # submit
  #
  test "should redirect submit when not logged in" do
    schedule = JSON.parse(File.read('test/json/schedule.json'))
    post :submit, { :employee => { 'schedule' => schedule } }, :format => "json"
    assert_redirected_to login_url
  end

  test "should POST data to replicon when logged in" do
    sign_in(@agent)
    get :index
    assert_response :success

    schedule = JSON.parse(File.read('test/json/schedule.json'))
    post :submit, { :employee => { 'schedule' => schedule } }, :format => "json"
    assert_response :success

    assert_requested(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&features%5B%5D=2&features%5B%5D=3&features%5B%5D=4&features%5B%5D=5&features%5B%5D=6&name=Daniel%20Bidulock", :headers => {'Content-Type'=>'application/json'} )

    response = assigns(:response)
    assert_not_nil response

    assert_equal 'Thanks!', response['thank_you']
    assert_equal schedule, response['submission']
  end

  test "should redirect if solution=true and not logged in as admin" do
    sign_in(@agent)
    get :index
    assert_response :success

    schedule = JSON.parse(File.read('test/json/schedule.json'))
    post :submit, { :employee => { 'schedule' => schedule, 'solution' => '1' } }, :format => "json"
    assert_redirected_to root_path 

    assert_not_requested(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&features%5B%5D=2&features%5B%5D=3&features%5B%5D=4&features%5B%5D=5&features%5B%5D=6&name=Daniel%20Bidulock", :headers => {'Content-Type'=>'application/json'} )

    assert_not_requested(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&features%5B%5D=2&features%5B%5D=3&features%5B%5D=4&features%5B%5D=5&features%5B%5D=6&name=Daniel%20Bidulock&solution=true", :headers => {'Content-Type'=>'application/json'} )

    assert_equal 'Only an administrator can submit for real', flash[:error]
  end

  test "should POST data to replicon if solution-true and administrator is logged in" do
    sign_in(@admin)
    get :index
    assert_response :success

    schedule = JSON.parse(File.read('test/json/schedule.json'))
    post :submit, { :employee => { 'schedule' => schedule, 'solution' => '1' } }, :format => "json"
    assert_response :success

    assert_requested(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&features%5B%5D=2&features%5B%5D=3&features%5B%5D=4&features%5B%5D=5&features%5B%5D=6&name=Daniel%20Bidulock&solution=true", :headers => {'Content-Type'=>'application/json'} )

    response = assigns(:response)
    assert_not_nil response

    assert_equal 'Thanks!', response['thank_you']
    assert_equal schedule, response['submission']
  end
end
