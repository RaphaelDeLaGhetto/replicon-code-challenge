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

  # Capybara
  #
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  ## selenium
  options = {}
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, options)
  end
  # Uncomment to leave we browser open after test completes
  # 2015-9-12 http://stackoverflow.com/questions/7555416/how-to-leave-browser-opened-even-after-selenium-ruby-script-finishes/12211500#12211500
  # Also, it may be necessary to comment the teardown
#  Capybara::Selenium::Driver.class_eval do
#    def quit
#      puts "Press RETURN to quit the browser"
#      $stdin.gets
#      @browser.quit
#    rescue Errno::ECONNREFUSED
#      # Browser must have already gone
#    end
#  end

  Capybara.ignore_hidden_elements = false

  ## poltergeist
#  options = { js_errors: false }
#  Capybara.register_driver :poltergeist do |app|
#    Capybara::Poltergeist::Driver.new(app, options)
#  end

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

    stub_request(:get, "#{DOMAIN}/time-off/requests").
        to_return(:body => File.new('test/json/timeoff.json'), :status => 200)

    stub_request(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&features%5B%5D=2&features%5B%5D=3&features%5B%5D=4&features%5B%5D=5&features%5B%5D=6&name=Daniel%20Bidulock").
        to_return(:body => { thank_you: 'Thanks!', :submission => JSON.parse(File.read('test/json/schedule.json')) }.to_json,
                  :headers => {'Content-Type' => 'application/json'})

    stub_request(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&features%5B%5D=2&features%5B%5D=3&features%5B%5D=4&features%5B%5D=5&features%5B%5D=6&name=Daniel%20Bidulock&solution=true").
        to_return(:body => { thank_you: 'Thanks!', :submission => JSON.parse(File.read('test/json/schedule.json')) }.to_json,
                  :headers => {'Content-Type' => 'application/json'})
  end
end

# As per https://github.com/plataformatec/devise#test-helpers
class ActionController::TestCase
  include Devise::TestHelpers
end

#
# This is for testing concerns. It overrides routes and views
#
module MyEngine
  class Engine < Rails::Engine
  end
end

MyEngine::Engine.routes.draw do
  get "/" => "api_dummy#index"
end
