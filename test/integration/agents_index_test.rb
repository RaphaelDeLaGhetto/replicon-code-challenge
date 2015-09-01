require 'test_helper'

class AgentsIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = agents(:daniel)
    @agent = agents(:archer)
  end

  test "index as admin including pagination with edit and delete links and a button to add a new agent" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    get agents_path
    assert_template 'agents/index'

    # Only an admin can add a new agent
    assert_select 'form[action=?]', new_agent_path, text: "Add a new agent", count: 1 
    assert_select 'div.pagination'
    first_page_of_agents = Agent.paginate(page: 1)
    first_page_of_agents.each do |agent|
      assert_select 'a[href=?]', agent_path(agent), text: agent.name
      unless agent == @admin
        assert_select 'a[href=?][data-method="delete"]', agent_path(agent), method: :delete, count: 1
      end
      assert_select 'a[href=?]', edit_agent_path(agent), method: :edit
    end
    assert_difference 'Agent.count', -1 do
      delete agent_path(@agent)
    end
  end

  test "redirect index for non-admin" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    # Only an admin can view all agents
    get agents_path
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'static_pages/home'
  end
end
