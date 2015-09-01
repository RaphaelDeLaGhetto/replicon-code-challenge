require 'test_helper'

class AgentsLoginTest < ActionDispatch::IntegrationTest

  def setup
    @agent = agents(:archer)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'

    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': '', 'agent[password]': ''

    # Didn't go anywhere
    assert_template 'sessions/new'

    assert_equal 'Invalid email or password.', flash[:alert]
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    assert_template 'sessions/new'

    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email, 'agent[password]': 'password'
    assert_template 'static_pages/home'
    assert_equal 'Signed in successfully.', flash[:notice]

    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", agent_path(@agent)

    get logout_path
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", logout_path, count: 0

    # Simulate a agent clicking logout in a second window.
    get logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", agent_path(@agent), count: 0
  end

  test "login with remembering" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email,
                                          'agent[password]': 'password',
                                          'agent[remember_me]': '1'
    assert_template 'static_pages/home'
    assert_equal 'Signed in successfully.', flash[:notice]

    assert @request.cookie_jar.has_key?('remember_agent_token')
  end

  test "login without remembering" do
    # Sign in
    post_via_redirect agent_session_path, 'agent[email]': @agent.email,
                                          'agent[password]': 'password',
                                          'agent[remember_me]': '0'
    assert_template 'static_pages/home'
    assert_equal 'Signed in successfully.', flash[:notice]

    assert_not @request.cookie_jar.has_key?('remember_agent_token')
  end
end
