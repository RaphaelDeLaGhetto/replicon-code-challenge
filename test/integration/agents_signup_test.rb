require 'test_helper'

class AgentsSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get new_agent_registration_path
    assert_template 'registrations/new'

    assert_select "#agent_admin", count: 0
    assert_no_difference 'Agent.count' do
      post agents_path, agent: { name:  "",
                                 email: "agent@invalid",
                                 password: "foo",
                                 password_confirmation: "bar" }
    end
    assert_template 'registrations/new'
  end

  test "invalid admin signup" do
    get new_agent_registration_path
    assert_template 'registrations/new'

    assert_select "#agent_admin", count: 0
    assert_no_difference 'Agent.count' do
      post agents_path, agent: { name:  "Example Agent",
                                 email: "agent@example.com",
                                 password: "password",
                                 password_confirmation: "password",
                                 admin: true }
    end
    assert_redirected_to root_path
    assert_equal 'You cannot create an admin agent', flash[:danger]
  end

  test "valid signup information with account activation" do
    get new_agent_registration_path
    assert_template 'registrations/new'

    assert_select "#agent_admin", count: 0
    assert_difference 'Agent.count', 1 do
      post agents_path, agent: { name:  "Example Agent",
                                 email: "agent@example.com",
                                 password: "password",
                                 password_confirmation: "password" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    agent = assigns(:agent)
    assert_not agent.confirmed?

    # Try to log in before activation.
    post_via_redirect agent_session_path, 'agent[email]': 'agent@example.com', 'agent[password]': 'password'
    assert_equal 'You have to confirm your email address before continuing.', flash[:alert]
 
    # Invalid activation token
    get agent_confirmation_path confirmation_token: "invalid token"
    
    ## Ensure not logged in
    post_via_redirect agent_session_path, 'agent[email]': 'agent@example.com', 'agent[password]': 'password'
    assert_equal 'You have to confirm your email address before continuing.', flash[:alert]
 
    # Valid activation token
    get agent_confirmation_path confirmation_token: agent.confirmation_token
    assert_redirected_to new_agent_session_url
    follow_redirect!
    assert_template 'agents/sessions/new'

    assert_not agent.reload.confirmed_at.nil?

    ## Ensure logged in
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", logout_path, count: 0
  end
end
