require 'test_helper'

class AgentsAddTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @admin = agents(:daniel)
    @agent = agents(:archer)
  end

  test "invalid signup information" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    # Go to create new agent page
    get new_agent_path
    assert_template 'agents/new'
    assert_select "#agent_admin", count: 1

    # Sign up agent with empty name field 
    assert_no_difference 'Agent.count' do
      post_via_redirect agents_path, agent: { name:  "",
                                              email: "agent@invalid",
                                              password: "foo",
                                              password_confirmation: "bar" }
    end
    assert_template 'agents/registrations/new'
  end

  test "invalid non-admin signup" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    # Go to create new agent page
    get new_agent_path
    assert_select "#agent_admin", count: 0

    # Non-admin agents can't sign up new agents
    assert_no_difference 'Agent.count' do
      post agents_path, agent: { name:  "Example Agent",
                                 email: "agent@example.com",
                                 password: "password",
                                 password_confirmation: "password",
                                 admin: true }
    end
    assert_redirected_to root_url
    assert_equal 'You are not authorized to access this page.', flash[:error]
  end


  test "valid signup information with account activation" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    # Go to create new agent page
    get new_agent_path
    assert_select "#agent_admin", count: 1

    # Good data from an admin
    assert_difference 'Agent.count', 1 do
      post agents_path, agent: { name:  "Example Agent",
                                 email: "agent@example.com",
                                 password: "password",
                                 password_confirmation: "password",
                                 admin: false }
    end

    agent = assigns(:agent)
    assert_not agent.confirmed?

    assert_equal 1, ActionMailer::Base.deliveries.size

    # Ensure email is sent with correct details
    mail = Devise.mailer.deliveries.last
    assert_equal "Confirmation instructions", mail.subject
    assert_equal [agent.email], mail.to
    assert_equal [ENV["default_from"]], mail.from
    assert_match agent.email,              mail.body.encoded
    assert_match agent.confirmation_token, mail.body.encoded

    # admin was signed in
    get logout_path

    # Try to log in before activation.
    post agent_session_path, 'agent[email]': agent.email, 'agent[password]': 'password'
    assert_equal 'You have to confirm your email address before continuing.', flash[:alert]
    assert_redirected_to agent_session_url

    # Invalid activation token
    get agent_confirmation_path, :confirmation_token => "invalid token"
    assert_not agent.reload.confirmed?
    assert_template 'agents/confirmations/new'

    # Valid activation token
    get agent_confirmation_path, :confirmation_token => agent.confirmation_token
    assert agent.reload.confirmed?
    follow_redirect!
    assert_template 'agents/sessions/new'
  end

  test "valid admin signup information with account activation" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @admin.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'

    # Go to create new agent page
    get new_agent_path
    assert_select "#agent_admin", count: 1

    # Good data from an admin
    assert_difference 'Agent.count', 1 do
      post agents_path, agent: { name:  "Example Agent",
                                 email: "agent@example.com",
                                 password: "password",
                                 password_confirmation: "password",
                                 admin: true }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    agent = assigns(:agent)
    assert agent.admin?
    assert_not agent.confirmed?

    # admin was signed in
    get logout_path

    # Try to log in before activation.
    post agent_session_path, 'agent[email]': agent.email, 'agent[password]': 'password'
    assert_equal 'You have to confirm your email address before continuing.', flash[:alert]
    assert_redirected_to agent_session_url

    # Invalid activation token
    get agent_confirmation_path, :confirmation_token => "invalid token"
    assert_not agent.reload.confirmed?
    assert_template 'agents/confirmations/new'

    # Valid activation token
    get agent_confirmation_path, :confirmation_token => agent.confirmation_token
    assert agent.reload.confirmed?
    follow_redirect!
    assert_template 'agents/sessions/new'
  end
end
