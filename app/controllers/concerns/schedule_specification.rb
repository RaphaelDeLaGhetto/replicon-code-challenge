# 2015-9-8
# Specification pattern adapted from:
# https://gist.github.com/robuye/5517023
module ScheduleSpecification extend ActiveSupport::Concern
  module Generic
    class And
      def initialize(specs)
         @specifications = specs
      end
                      
      def is_satisfied_by?(subject)
        @specifications.all? do |spec|
          spec.is_satisfied_by?(subject)
        end
      end
    end
                        
    class Or
      def initialize(specs)
        @specifications = specs
      end
                      
      def is_satisfied_by?(subject)
        @specifications.any? do |spec|
          spec.is_satisfied_by?(subject)
        end
      end
    end
                        
    class Not
      def initialize(spec)
        @spec = spec
      end
                      
      def is_satisfied_by?(subject)
        !@spec.is_satisfied_by?(subject)
      end
    end
  end

  #
  # Examine an employees schedule and execute block
  #
  def self.find_employee_in_schedule(schedule, subject, &block)
    schedule.each do |sched|
      if sched[:week] == subject[:week]
        sched[:schedules].each do |s|
          if s[:employee_id] == subject[:employee_id]
            return block.call(s, subject)
          end
        end
      end
    end   
  end

  #
  # Consider employees' requests for time off
  #
  class RequestedTimeoff
    def initialize(timeoff_requests)
      @timeoff_requests = timeoff_requests
    end

    def is_satisfied_by?(subject)
      timeoff_requested = false
      @timeoff_requests.each do |request|
        timeoff_requested = true if request['employee_id'] == subject[:employee_id] &&
                                    request['week'] == subject[:week] &&
                                    request['days'].include?(subject[:day])
        break if timeoff_requested 
      end
      timeoff_requested
    end
  end

  #
  # Consider the maximum allowable shifts per week 
  #
  class ExceedsMaxShifts
    def initialize(schedule, shift_rules, rule_definitions)
      @schedule = schedule

      # Find the ID associated with the MAX_SHIFTS rule
      rule_id = nil
      rule_definitions.each do |definition|
        rule_id = definition['id'] if definition['value'] == 'MAX_SHIFTS'
      end

      # Pick out the applicable rules
      @shift_rules = []
      shift_rules.each do |rule|
        @shift_rules << rule if rule['rule_id'] == rule_id
      end

      # Determine corporate rule
      @corporate_max = nil
      @shift_rules.each do |rule|
        @corporate_max = rule['value'] if !rule['employee_id'] 
        break if @corporate_max
      end
    end

    def is_satisfied_by?(subject)
      exceeds_max_shifts = false
      max_shifts = @corporate_max

      # Determine if this employee has special rules
      @shift_rules.each do |rule|
        if rule['employee_id'] && rule['employee_id'] == subject[:employee_id]
          max_shifts = rule['value']  
        end
      end

      # Find the week and count the number of scheduled shifts
      ScheduleSpecification.find_employee_in_schedule(@schedule, subject) do |sched, subject|
        exceeds_max_shifts = sched[:schedule].count >= max_shifts 
      end

      exceeds_max_shifts
    end
  end

  #
  # Consider the minimum number of shifts an employee should expect per week 
  #
  class NeedsMoreShifts
    def initialize(schedule, shift_rules, rule_definitions)
      @schedule = schedule

      # Find the ID associated with the MIN_SHIFTS rule
      rule_id = nil
      rule_definitions.each do |definition|
        rule_id = definition['id'] if definition['value'] == 'MIN_SHIFTS'
      end

      # Pick out the applicable rules
      @shift_rules = []
      shift_rules.each do |rule|
        @shift_rules << rule if rule['rule_id'] == rule_id
      end

      # Determine corporate rule
      @corporate_min = nil
      @shift_rules.each do |rule|
        @corporate_min = rule['value'] if !rule['employee_id'] 
        break if @corporate_min
      end
    end

    def is_satisfied_by?(subject)
      needs_more_shifts = true
      min_shifts = @corporate_min

      # Determine if this employee has special rules
      @shift_rules.each do |rule|
        if rule['employee_id'] && rule['employee_id'] == subject[:employee_id]
          min_shifts = rule['value']  
        end
      end

      # Find the week and count the number of scheduled shifts
      ScheduleSpecification.find_employee_in_schedule(@schedule, subject) do |sched, subject|
        needs_more_shifts = !(sched[:schedule].count >= min_shifts) 
      end

      needs_more_shifts
    end
  end

  #
  # Return true if an employee is already scheduled that shift
  #
  class AlreadyScheduled
    def initialize(schedule, employees)
      @schedule = schedule
      @employees = employees
    end

    def is_satisfied_by?(subject)
      already_scheduled = false
      ScheduleSpecification.find_employee_in_schedule(@schedule, subject) do |sched, subject|
        already_scheduled = sched[:schedule].include?(subject[:day])
      end
      already_scheduled
    end
  end
 
  #
  # Determine if an employee is available to work the shift specified
  #
  class IsAvailable
    def initialize(schedule, employees, timeoff_requests, shift_rules, rule_definitions)
      @schedule = schedule
      @employees = employees
      @timeoff_requests = timeoff_requests
      @shift_rules = shift_rules
      @rule_definitions = rule_definitions
    end

    def is_satisfied_by?(subject)
      specification.is_satisfied_by?(subject)
    end

    private
      def specification
        Generic::And.new([no_timeoff_requested, does_not_exceed_max_shifts, needs_more_shifts, not_aready_scheduled])
      end

      def no_timeoff_requested
        Generic::Not.new(RequestedTimeoff.new(@timeoff_requests))
      end

      def does_not_exceed_max_shifts
        Generic::Not.new(ExceedsMaxShifts.new(@schedule, @shift_rules, @rule_definitions))
      end

      def needs_more_shifts
        NeedsMoreShifts.new(@schedule, @shift_rules, @rule_definitions)
      end

      def not_aready_scheduled
        Generic::Not.new(AlreadyScheduled.new(@schedule, @employees))
      end
  end
end
