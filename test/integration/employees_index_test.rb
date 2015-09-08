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
    WebMock.reset!
  end

  test "index as authorized agent" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email, 'agent[password]': 'password'
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
    assert page.has_selector?("#LannyMcDonald", count: 10)
    assert page.has_selector?("#DaveSapunjis", count: 10)
    assert page.has_selector?("#GaryRoberts", count: 13)
    assert page.has_selector?("#MikeVernon", count: 12)
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
    assert page.has_selector?('#thank-you', text: 'Thanks!')

    schedule = JSON.parse(File.read('test/json/schedule.json'))
    assert page.has_selector?('#submitted', visible: true)
  end

  test "should submit the schedule to Replicon for real" do
    # Sign in
    visit login_path
    fill_in 'Email', with: 'hands@example.gov'
    fill_in 'Password', with: 'password'
    click_button "Log in"

    visit(employees_path)

    # Check the submit-for-real box
    find(:css, '#for-real').set(true)
    click_on 'Submit schedule'

    assert_requested(:post, "#{DOMAIN}/submit?email=daniel@bidulock.ca&features%5B%5D=1&name=Daniel%20Bidulock&solution=true")

    assert page.has_selector?('#thank-you', text: 'Thanks!')
    schedule = JSON.parse(File.read('test/json/schedule.json'))
    assert page.has_selector?('#submitted', visible: true)
  end
end
