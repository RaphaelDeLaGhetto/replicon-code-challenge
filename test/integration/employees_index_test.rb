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

  def teardown
    delete destroy_agent_session_path
    Capybara.reset_sessions!
  end

  test "index as authorized agent" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    get employees_path
    assert_template 'employees/index'

    # Ensure the correct number of employees are displayed
    # +1 for the 'Show all' link
    assert_select 'ul.employees>li', count: 5+1
    @employees.each do |employee|
      assert_select 'a[data-employee-id=?]', employee['name'].gsub(/[^0-9A-Za-z]/, ''), count: 1
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
    assert page.has_selector?("#AllenPitts", count: 11)
    assert page.has_selector?("#LannyMcDonald", count: 12)
    assert page.has_selector?("#DaveSapunjis", count: 11)
    assert page.has_selector?("#GaryRoberts", count: 11)
    assert page.has_selector?("#MikeVernon", count: 11)
  end

  test "should toggle coworker schedule visibility when employee link is clicked" do
    # Sign in
    visit login_path
    fill_in 'Email', with: 'hands@example.gov'
    fill_in 'Password', with: 'password'
    click_button "Log in"

    visit(employees_path)

    click_on 'Lanny McDonald'
    assert page.has_selector?('#LannyMcDonald', visible: true)
    assert page.has_selector?('#AllenPitts', visible: false)
    assert page.has_selector?("#DaveSapunjis", visible: false)
    assert page.has_selector?("#GaryRoberts", visible: false)
    assert page.has_selector?("#MikeVernon", visible: false)

    click_on 'Mike Vernon'
    assert page.has_selector?("#MikeVernon", visible: true)
    assert page.has_selector?('#LannyMcDonald', visible: false)
    assert page.has_selector?('#AllenPitts', visible: false)
    assert page.has_selector?("#DaveSapunjis", visible: false)
    assert page.has_selector?("#GaryRoberts", visible: false)

    click_on 'Show all'
    assert page.has_selector?("#MikeVernon", visible: true)
    assert page.has_selector?('#LannyMcDonald', visible: true)
    assert page.has_selector?('#AllenPitts', visible: true)
    assert page.has_selector?("#DaveSapunjis", visible: true)
    assert page.has_selector?("#GaryRoberts", visible: true)
  end

  test "should submit the schedule to Replicon" do
    # Sign in
    visit login_path
    fill_in 'Email', with: 'hands@example.gov'
    fill_in 'Password', with: 'password'
    click_button "Log in"

    visit(employees_path)

    click_on 'Submit schedule'

  end
end
