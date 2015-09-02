require 'test_helper'

class EmployeesIndexTest < ActionDispatch::IntegrationTest

  def setup
    @agent = agents(:archer)

    mock_api

    @employees = JSON.parse(File.read('test/json/employees.json'))
  end

  test "index as agent including pagination with edit and delete links and a button to add a new agent" do
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


end
