require 'test_helper'

class ApiDummyController < ApplicationController
  include Scheduler
  def index
  end
end

class ApiDummyControllerTest < ActionController::TestCase
  tests ApiDummyController

  def setup
    @routes = MyEngine::Engine.routes
    mock_api
  end

  test "should set the events instance variable" do
    get :index
    assert_response :success

    events = assigns(:events)
    assert_not_nil events

    # 4 weeks x 7 days x 2 employees per day
    assert_equal 4*7*2, events.count

#    assert_equal 'Lanny McDonald', events[0][:title]
#    assert_equal 'LannyMcDonald', events[0][:id]
    assert_equal '2015-06-01', events[0][:start]

    assert_equal events[-1][:id], events[-1][:title].gsub(/[^0-9A-Za-z]/, '')
    assert_equal '2015-06-28', events[-1][:start]
  end

  test "should set the schedule instance variable" do
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

  test "should force scheduling if there are too many time off requests" do
    stub_request(:get, "#{DOMAIN}/time-off/requests").
        to_return(:body => File.new('test/json/too_much_timeoff.json'), :status => 200)

    get :index
    assert_response :success

    schedule = assigns(:schedule)
    assert_not_nil schedule

    assert_equal 4, schedule.count

    # Week 23
    assert_equal 23, schedule[0][:week]
    assert_equal 5, schedule[0][:schedules].count

    # Week 24
    # (Note the count: Someone got some time off)
    assert_equal 24, schedule[1][:week]
    assert_equal 4, schedule[1][:schedules].count

    # Week 25
    assert_equal 25, schedule[2][:week]
    assert_equal 5, schedule[2][:schedules].count

    # Week 26
    assert_equal 26, schedule[3][:week]
    assert_equal 5, schedule[3][:schedules].count
  end

  test "should ensure every employee gets the minimum number of shifts" do
    get :index
    assert_response :success

    schedule = assigns(:schedule)
    assert_not_nil schedule

    assert_equal 4, schedule.count

    # Week 23
    puts schedule.inspect
    assert_equal 23, schedule[0][:week]
    assert_equal 5, schedule[0][:schedules].count
    assert_equal 2, schedule[0][:schedules][0][:employee_id]
    assert_equal 5, schedule[0][:schedules][0][:schedule].count
    assert_equal 5, schedule[0][:schedules][1][:employee_id]
    assert_equal 5, schedule[0][:schedules][1][:schedule].count
    assert_equal 5, schedule[0][:schedules][2][:employee_id]
    assert_equal 5, schedule[0][:schedules][2][:schedule].count
    assert_equal 5, schedule[0][:schedules][3][:employee_id]
    assert_equal 5, schedule[0][:schedules][3][:schedule].count
    assert_equal 5, schedule[0][:schedules][4][:employee_id]
    assert_equal 5, schedule[0][:schedules][4][:schedule].count

    # Week 24
    # (Note the count: Someone got some time off)
    assert_equal 24, schedule[1][:week]
    assert_equal 4, schedule[1][:schedules].count

    # Week 25
    assert_equal 25, schedule[2][:week]
    assert_equal 5, schedule[2][:schedules].count

    # Week 26
    assert_equal 26, schedule[3][:week]
    assert_equal 5, schedule[3][:schedules].count

  end
end
