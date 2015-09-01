require 'test_helper'

class AgentsControllerTest < ActionController::TestCase
  should use_before_action :set_agent

  def setup
    @admin = agents(:daniel)
    @agent = agents(:archer)
  end

  #
  # index
  #
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  #
  # show
  #
  test "should redirect show when not logged in" do
    get :show, id: @agent
    assert_redirected_to login_url
  end

  test "should show when logged in" do
    sign_in(@agent)
    get :show, id: @agent
    assert_response :success
  end

  #
  # new
  #
  test "should redirect get new if not signed in as admin" do
    get :new
    assert_redirected_to login_path
    assert_equal 'You are not authorized to access this page.', flash[:error]
  end

  test "should redirect get new if signed in as non-admin" do
    sign_in @agent
    get :new
    assert_redirected_to root_path
    assert_equal 'You are not authorized to access this page.', flash[:error]
  end

  test "should get new if signed in as admin" do
    sign_in @admin
    get :new
    assert_response :success
    assert_template 'agents/new'
    assert_select "title", "Create agent | #{ENV['app_title']}"
  end

  #
  # edit
  #
  test "should redirect edit when not logged in" do
    get :edit, id: @admin
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong agent" do
    sign_in(@agent)
    get :edit, id: @admin
    assert_equal 'You are not authorized to access this page.', flash[:error]
    assert_redirected_to root_url
  end

  test "should allow admin to edit agent" do
    sign_in(@admin)
    get :edit, id: @agent
    assert_response :success
  end

  #
  # update
  #
  test "should redirect update when not logged in" do
    patch :update, id: @admin, agent: { name: @admin.name, email: @admin.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when logged in as wrong agent" do
    sign_in(@agent)
    patch :update, id: @admin, agent: { name: @admin.name, email: @admin.email }
    assert_equal 'You are not authorized to access this page.', flash[:error]
    assert_redirected_to root_url
  end

  test "should allow admin to update agent" do
    sign_in(@admin)
    assert_not @agent.admin
    patch :update, id: @agent, agent: { name: 'Bojack Horseman',
                                        email: 'bojack@netflix.com' }
    assert_redirected_to @agent
    @agent.reload
    assert_equal 'Bojack Horseman', @agent.name
    assert_equal 'duchess@example.gov', @agent.email
    assert_equal 'bojack@netflix.com', @agent.unconfirmed_email
    assert !@agent.confirmation_token.nil?
  end

  test "should not allow a non-admin to edit the admin attribute via the web" do
    sign_in(@agent)
    assert_not @agent.admin?
    patch :update, id: @agent, agent: { password: 'somejunk',
                                        password_confirmation: 'somejunk',
                                        admin: true }
    assert_not @agent.reload.admin
  end

  test "should allow an admin to edit the admin attribute via the web" do
    sign_in(@admin)
    assert @admin.admin?
    patch :update, id: @agent, agent: { password: 'somejunk',
                                        password_confirmation: 'somejunk',
                                        admin: true }
    assert @agent.reload.admin?
  end

  #
  # destroy
  #
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Agent.count' do
      delete :destroy, id: @admin
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    sign_in(@agent)
    assert_no_difference 'Agent.count' do
      delete :destroy, id: @admin
    end
    assert_redirected_to root_url
  end

  test "should allow admin to destroy agent" do
    sign_in(@admin)
    assert_difference 'Agent.count', -1 do
      delete :destroy, id: @admin
    end
    assert_redirected_to agents_url
  end
end
