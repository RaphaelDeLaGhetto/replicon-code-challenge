ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'devise'
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include ApplicationHelper

  #
  # mock_api
  #
  # This app makes a lot of API calls, which need to be mocked in various tests
  DOMAIN = 'http://interviewtest.replicon.com'
  def mock_api
    stub_request(:get, "#{DOMAIN}/employees").
        to_return(:body => File.new('test/json/employees.json'), :status => 200)

    stub_request(:get, "#{DOMAIN}/shift-rules").
        to_return(:body => File.new('test/json/shift_rules.json'), :status => 200)

    stub_request(:get, "#{DOMAIN}/ruledefinitions").
        to_return(:body => File.new('test/json/ruledefinitions.json'), :status => 200)

    stub_request(:get, "#{DOMAIN}/weeks/23").
        to_return(:body => File.new('test/json/week_23.json'), :status => 200)

    stub_request(:get, "#{DOMAIN}/weeks/26").
        to_return(:body => File.new('test/json/week_26.json'), :status => 200)
  end

end

# As per https://github.com/plataformatec/devise#test-helpers
class ActionController::TestCase
  include Devise::TestHelpers
end

