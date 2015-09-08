require 'test_helper'

class DummyController < ApplicationController
  include ScheduleSpecification
  def index
  end
end

class DummyControllerTest < ActionController::TestCase
 

  def setup
    @employees = JSON.parse(File.read('test/json/employees.json'))
    @timeoff = JSON.parse(File.read('test/json/timeoff.json'))
  end

  #
  # IsAvailable
  #
  test "should return true if employee did not request time off" do
    available_spec = ScheduleSpecification::IsAvailable.new(@employees, @timeoff)
    assert available_spec.is_satisfied_by?({ employee_id: 1, week: 23, day: 4 })
    assert available_spec.is_satisfied_by?({ employee_id: 2, week: 23, day: 1 })
    assert available_spec.is_satisfied_by?({ employee_id: 5, week: 26, day: 4 })
    assert available_spec.is_satisfied_by?({ employee_id: 2, week: 26, day: 2 })
  end
 
  test "should return false if employee requested time off" do
    available_spec = ScheduleSpecification::IsAvailable.new(@employees, @timeoff)
    assert_not available_spec.is_satisfied_by?({ employee_id: 1, week: 23, day: 1 })
    assert_not available_spec.is_satisfied_by?({ employee_id: 2, week: 23, day: 7 })
    assert_not available_spec.is_satisfied_by?({ employee_id: 5, week: 26, day: 3 })
    assert_not available_spec.is_satisfied_by?({ employee_id: 2, week: 26, day: 1 })
  end

  #
  # RequestedTimeoff
  #
  test "should return true if time off was requested" do
    timeoff_spec = ScheduleSpecification::RequestedTimeoff.new(@timeoff)
    assert timeoff_spec.is_satisfied_by?({ employee_id: 1, week: 23, day: 1 })
    assert timeoff_spec.is_satisfied_by?({ employee_id: 2, week: 23, day: 7 })
    assert timeoff_spec.is_satisfied_by?({ employee_id: 5, week: 26, day: 3 })
    assert timeoff_spec.is_satisfied_by?({ employee_id: 2, week: 26, day: 1 })
  end

  test "should return false if no time off was requested" do
    timeoff_spec = ScheduleSpecification::RequestedTimeoff.new(@timeoff)
    assert_not timeoff_spec.is_satisfied_by?({ employee_id: 1, week: 23, day: 4 })
    assert_not timeoff_spec.is_satisfied_by?({ employee_id: 2, week: 23, day: 1 })
    assert_not timeoff_spec.is_satisfied_by?({ employee_id: 5, week: 26, day: 4 })
    assert_not timeoff_spec.is_satisfied_by?({ employee_id: 2, week: 26, day: 2 })
  end

end
