require 'test_helper'

class AgentsEditTest < ActionDispatch::IntegrationTest
  def setup
    @admin = agents(:daniel)
  end

  test "unsuccessful edit" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    get edit_agent_path(@admin)
    assert_template 'agents/edit'
    patch agent_path(@admin), agent: { name:  "",
                                       email: "foo@invalid",
                                       password: "foo",
                                       password_confirmation: "bar" }
    assert_template 'agents/edit'
  end

  test "successful edit" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    get edit_agent_path(@admin)
    assert_template 'agents/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch agent_path(@admin), agent: { name:  name,
                                       email: email,
                                       password:              "",
                                       password_confirmation: "" }
    assert_equal 'Successfully updated Agent.', flash[:notice]
    assert_redirected_to @admin
    @admin.reload
    assert_equal name, @admin.name
    assert_equal email, @admin.unconfirmed_email
  end

  test "successful admin edit" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    other_agent = agents(:lana)
    get edit_agent_path(other_agent)
    assert_template 'agents/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch agent_path(other_agent), agent: { name:  name,
                                       email: email,
                                       password:              "",
                                       password_confirmation: "" }
    assert_equal 'Successfully updated Agent.', flash[:notice]
    assert_redirected_to other_agent
    other_agent.reload
    assert_equal name, other_agent.name
    assert_equal email, other_agent.unconfirmed_email
  end

  test "successful edit with friendly forwarding" do
    get edit_agent_path(@admin)
    assert_redirected_to login_path

    # Sign in
    post agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_redirected_to edit_agent_path(@admin) 
    follow_redirect!

    assert_template 'agents/edit'

    name  = "Foo Bar"
    email = "foo@bar.com"
    patch agent_path(@admin), agent: { name:  name,
                                       email: email,
                                       password: "foobarbaz",
                                       password_confirmation: "foobarbaz" }
    assert_equal 'Successfully updated Agent.', flash[:notice]
    assert_redirected_to @admin
    @admin.reload
    assert_equal name, @admin.name
    assert_equal email, @admin.unconfirmed_email
  end
end
