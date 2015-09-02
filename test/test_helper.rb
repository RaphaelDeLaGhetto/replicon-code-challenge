ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'devise'
require 'webmock/minitest'
require 'capybara/rails'
require 'capybara/poltergeist'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include ApplicationHelper

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  ## selenium
#  options = {}
#  Capybara.register_driver :selenium do |app|
#    Capybara::Selenium::Driver.new(app, options)
#  end

  ## poltergeist
  options = { js_errors: false }
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, options)
  end

  #
  # mock_api
  #
  # This app makes a lot of API calls, which need to be mocked in various tests
  WebMock.disable_net_connect!(:allow_localhost => true)
  DOMAIN = 'http://interviewtest.replicon.com'
  def mock_api
    stub_request(:get, "#{DOMAIN}/employees").
        to_return(:body => File.new('test/json/employees.json'), :status => 200)

    stub_request(:get, "#{DOMAIN}/shift-rules").
        to_return(:body => File.new('test/json/shift_rules.json'), :status => 200)

    stub_request(:get, "#{DOMAIN}/rule-definitions").
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

