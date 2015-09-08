require 'test_helper'

class DummyController < ApplicationController
  include ScheduleSpecification
  def index
  end
end

class DummyControllerTest < ActionController::TestCase

  def setup
    @schedule = []
    @employees = JSON.parse(File.read('test/json/employees.json'))
    @timeoff = JSON.parse(File.read('test/json/timeoff.json'))
    @shift_rules = JSON.parse(File.read('test/json/shift_rules.json'))
    @rule_definitions = JSON.parse(File.read('test/json/ruledefinitions.json'))
  end

  #
  # IsAvailable
  #
  test "should return true if employee did not request time off" do
    available_spec = ScheduleSpecification::IsAvailable.new(@schedule, @employees, @timeoff, @shift_rules, @rule_definitions)
    assert available_spec.is_satisfied_by?({ employee_id: 1, week: 23, day: 4 })
    assert available_spec.is_satisfied_by?({ employee_id: 2, week: 23, day: 1 })
    assert available_spec.is_satisfied_by?({ employee_id: 5, week: 26, day: 4 })
    assert available_spec.is_satisfied_by?({ employee_id: 2, week: 26, day: 2 })
  end
 
  test "should return false if employee requested time off" do
    available_spec = ScheduleSpecification::IsAvailable.new(@schedule, @employees, @timeoff, @shift_rules, @rule_definitions)
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

  #
  # ExceedsMaxShifts
  #
  test "should return true if the employee has too many shifts according to corporate rules" do
    # Only corporate rules apply to employees 3 and 4 according to test data (max six)
    schedule = [
        {
            "week": 23,
            "schedules": [
                { "employee_id": 3, "schedule": [1, 2, 3, 4, 5, 6] },
                { "employee_id": 4, "schedule": [1, 2, 3, 4, 5, 6, 7] }
            ]
        }
    ]
    max_shifts_spec = ScheduleSpecification::ExceedsMaxShifts.new(schedule, @shift_rules, @rule_definitions)
    assert max_shifts_spec.is_satisfied_by?({ employee_id: 3, week: 23 })
    assert max_shifts_spec.is_satisfied_by?({ employee_id: 4, week: 23 })
  end

  test "should return true if the employee has too many shifts according to his personal rules" do
    # The personal rules for employees 1 and 2 are defined in the test data (max five each)
    schedule = [
        {
            "week": 23,
            "schedules": [
                { "employee_id": 1, "schedule": [1, 2, 3, 4, 5] },
                { "employee_id": 2, "schedule": [1, 2, 3, 4, 5, 6] }
            ]
        }
    ]
    max_shifts_spec = ScheduleSpecification::ExceedsMaxShifts.new(schedule, @shift_rules, @rule_definitions)
    assert max_shifts_spec.is_satisfied_by?({ employee_id: 1, week: 23 })
    assert max_shifts_spec.is_satisfied_by?({ employee_id: 2, week: 23 })
  end

  test "should return false if the employee has not reached the shift limit" do
    schedule = [
        {
            "week": 23,
            "schedules": [
                { "employee_id": 1, "schedule": [1, 2, 3, 4] },
                { "employee_id": 3, "schedule": [1, 2, 3, 4, 5] }
            ]
        }
    ]

    max_shifts_spec = ScheduleSpecification::ExceedsMaxShifts.new(schedule, @shift_rules, @rule_definitions)
    assert_not max_shifts_spec.is_satisfied_by?({ employee_id: 1, week: 23 })
    assert_not max_shifts_spec.is_satisfied_by?({ employee_id: 2, week: 23 })
    assert_not max_shifts_spec.is_satisfied_by?({ employee_id: 3, week: 23 })
    assert_not max_shifts_spec.is_satisfied_by?({ employee_id: 4, week: 23 })
  end

  #
  # NeedsMoreShifts
  #
  test "should return true if the employee doesn't have enough shifts according to corporate rules" do
    # Only corporate rules apply to employees 3 and 4 according to test data (min 2)
    schedule = [
        {
            "week": 23,
            "schedules": [
                { "employee_id": 3, "schedule": [1] }
            ]
        }
    ]
    min_shifts_spec = ScheduleSpecification::NeedsMoreShifts.new(schedule, @shift_rules, @rule_definitions)
    assert min_shifts_spec.is_satisfied_by?({ employee_id: 3, week: 23 })
    assert min_shifts_spec.is_satisfied_by?({ employee_id: 4, week: 23 })
  end

  test "should return true if the employee doesn't have enough shifts according to his personal rules" do
    # The personal rules for employees 1 and 2 are defined in the test data (min 3 and 5, respectively)
    schedule = [
        {
            "week": 23,
            "schedules": [
                { "employee_id": 1, "schedule": [1, 2] },
                { "employee_id": 2, "schedule": [1, 2, 3, 4] }
            ]
        }
    ]
    min_shifts_spec = ScheduleSpecification::NeedsMoreShifts.new(schedule, @shift_rules, @rule_definitions)
    assert min_shifts_spec.is_satisfied_by?({ employee_id: 1, week: 23 })
    assert min_shifts_spec.is_satisfied_by?({ employee_id: 2, week: 23 })
  end

  test "should return false if the employee meets or exceeds the minimum required shifts" do
    schedule = [
        {
            "week": 23,
            "schedules": [
                { "employee_id": 1, "schedule": [1, 2, 3, 4, 5] },
                { "employee_id": 2, "schedule": [1, 2, 3, 4, 5] },
                { "employee_id": 3, "schedule": [1, 2] },
                { "employee_id": 4, "schedule": [1, 2] }
            ]
        }
    ]

    min_shifts_spec = ScheduleSpecification::NeedsMoreShifts.new(schedule, @shift_rules, @rule_definitions)
    assert_not min_shifts_spec.is_satisfied_by?({ employee_id: 1, week: 23 })
    assert_not min_shifts_spec.is_satisfied_by?({ employee_id: 2, week: 23 })
    assert_not min_shifts_spec.is_satisfied_by?({ employee_id: 3, week: 23 })
    assert_not min_shifts_spec.is_satisfied_by?({ employee_id: 4, week: 23 })
  end
end
