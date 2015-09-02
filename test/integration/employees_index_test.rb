require 'test_helper'

class EmployeesIndexTest < ActionDispatch::IntegrationTest

  def setup
    Capybara.current_driver = :selenium
#    Capybara.current_driver = :poltergeist
#    Capybara.javascript_driver.js_errors = false

    @agent = agents(:archer)

    mock_api

    @employees = JSON.parse(File.read('test/json/employees.json'))
  end

  test "index as authorized agent" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    get employees_path
    assert_template 'employees/index'

    # Ensure the correct number of employees are displayed
    assert_select 'ul.employees>li', count: 5
    @employees.each do |employee|
      assert_select 'a[href=?]', employee_path(employee['id']), text: employee['name']
    end
  end


  test "should display the correct number of scheduled shifts for each employee" do

    # Sign in
    visit login_path
    fill_in 'Email', with: 'hands@example.gov'
    fill_in 'Password', with: 'password'
    click_button "Log in"

    visit(employees_path)
    assert page.has_selector?(".fc-toolbar", count: 1)
    assert page.has_selector?("#LannyMcDonald", count: 13)
#
#    get employees_path
#    assert_template 'employees/index'
#
#    assert_select '.fc-toolbar', count: 1
#    assert_select 'AllenPitts', count: 5
#    assert_select 'LannyMcDonald', count: 5

  end
end
