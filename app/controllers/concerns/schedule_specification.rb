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
        Generic::And.new([no_timeoff_requested])
      end

      def no_timeoff_requested
        Generic::Not.new(RequestedTimeoff.new(@timeoff_requests))
      end
  end
end
