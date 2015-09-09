require 'test_helper'

class ApiDummyController < ApplicationController
  include ApiCalls
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
    assert_equal 24, schedule[1][:week]
    assert_equal 5, schedule[1][:schedules].count

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
    assert_equal 23, schedule[0][:week]
    assert_equal 5, schedule[0][:schedules].count
    assert_equal 14, schedule[0][:schedules].inject(0) { |result, element| result + element[:schedule].count }

    schedule[0][:schedules].each do |sched|
      case sched[:employee_id]
      when 1
        assert sched[:schedule].count > 2
        assert_not sched[:schedule].include?(1)
        assert_not sched[:schedule].include?(2)
        assert_not sched[:schedule].include?(3)
      when 2
        assert sched[:schedule].count > 3
        assert_not sched[:schedule].include?(5)
        assert_not sched[:schedule].include?(6)
        assert_not sched[:schedule].include?(7)
      when 3
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(6)
        assert_not sched[:schedule].include?(7)
      when 4..5
        assert sched[:schedule].count > 1
      end
    end

    # Week 24
    assert_equal 24, schedule[1][:week]
    assert_equal 5, schedule[1][:schedules].count
    assert_equal 14, schedule[1][:schedules].inject(0) { |result, element| result + element[:schedule].count }

    schedule[1][:schedules].each do |sched|
      case sched[:employee_id]
      when 1
        assert sched[:schedule].count > 2
      when 2
        assert sched[:schedule].count > 4
      when 3
        assert sched[:schedule].count > 1
      when 4
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(1)
        assert_not sched[:schedule].include?(3)
        assert_not sched[:schedule].include?(4)
      when 5
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(5)
        assert_not sched[:schedule].include?(6)
        assert_not sched[:schedule].include?(7)
      end
    end

    # Week 25
    assert_equal 25, schedule[2][:week]
    assert_equal 5, schedule[2][:schedules].count
    assert_equal 14, schedule[2][:schedules].inject(0) { |result, element| result + element[:schedule].count }

    schedule[2][:schedules].each do |sched|
      case sched[:employee_id]
      when 1
#        assert sched[:schedule].count > 2
        assert_not sched[:schedule].include?(1)
        assert_not sched[:schedule].include?(2)
        assert_not sched[:schedule].include?(3)
        assert_not sched[:schedule].include?(7)
      when 2
        assert sched[:schedule].count > 4
      when 3
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(6)
        assert_not sched[:schedule].include?(7)
      when 4
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(5)
        assert_not sched[:schedule].include?(6)
        assert_not sched[:schedule].include?(7)
      when 5
        assert sched[:schedule].count > 1
      end
    end

    # Week 26
    assert_equal 26, schedule[3][:week]
    assert_equal 5, schedule[3][:schedules].count
    assert_equal 14, schedule[3][:schedules].inject(0) { |result, element| result + element[:schedule].count }

    schedule[3][:schedules].each do |sched|
      case sched[:employee_id]
      when 1
        assert sched[:schedule].count > 2
      when 2
#        assert sched[:schedule].count > 4
        assert_not sched[:schedule].include?(1)
      when 3
        assert sched[:schedule].count > 1
      when 4
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(1)
        assert_not sched[:schedule].include?(2)
        assert_not sched[:schedule].include?(3)
        assert_not sched[:schedule].include?(4)
      when 5
        assert sched[:schedule].count > 1
        assert_not sched[:schedule].include?(1)
        assert_not sched[:schedule].include?(2)
        assert_not sched[:schedule].include?(3)
      end
    end
  end
end
