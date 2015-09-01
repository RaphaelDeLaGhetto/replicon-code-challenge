require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @agent = agents(:archer)
  end

  test "password resets" do
    get new_agent_password_path
    assert_template 'agents/passwords/new'

    # Invalid email
    post agent_password_path, agent: { email: '' }
    assert_response :success 
    assert_template 'agents/passwords/new'

    # 2015-8-29 http://stackoverflow.com/questions/28963891/replace-devise-error-messages-with-flash-messages
    #assert_not flash.empty?

    # Valid email
    post agent_password_path, agent: { email: @agent.email }
    assert_not_equal @agent.reset_password_token, @agent.reload.reset_password_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to new_agent_session_url

    # Ensure email is sent with correct details
    mail = Devise.mailer.deliveries.last
    assert_equal "Reset password instructions", mail.subject
    assert_equal [@agent.email], mail.to
    assert_equal [ENV["default_from"]], mail.from
    assert_match @agent.email, mail.body.encoded

    # Get the email, and get the reset password token from it
    # 2015-8-29 http://iswwwup.com/t/80e86590311e/rails-4-devise-how-to-write-a-test-for-devise-reset-password-without-r.html
    message = ActionMailer::Base.deliveries[0].to_s
    rpt_index = message.index("reset_password_token")+"reset_password_token".length+1
    reset_password_token = message[rpt_index...message.index("\"", rpt_index)]

    # Password reset form
    get edit_agent_password_path, reset_password_token: @agent.reset_password_token
    assert_response :success 
    assert_template 'agents/passwords/edit'

    # Invalid password
    put agent_password_path,
          agent: { reset_password_token: reset_password_token,
                   password:              "foobaz12",
                   password_confirmation: "barquux1" }
    assert_select 'div#error_explanation'

    # Blank password
    put agent_password_path,
          agent: { reset_password_token: reset_password_token,
                   password:              " ",
                   password_confirmation: " " }
    assert_select 'div#error_explanation'

    # Valid password & confirmation
    put agent_password_path,
          agent: { reset_password_token: reset_password_token,
                   password:              "foobarbaz",
                   password_confirmation: "foobarbaz" }
    assert_select 'div#error_explanation', count: 0

    assert_not flash.empty?
    assert_redirected_to root_path
  end

#  test "password reset on inactive agent" do
#    get new_password_reset_path
#    assert_template 'password_resets/new'
#    # Valid email, inactive agent
#    assert_nil @agent.activation_token
#    assert_nil @agent.activation_digest
#    @agent.toggle!(:activated)
#    post password_resets_path, password_reset: { email: @agent.email }
#    assert_equal flash[:info], 'Please check your email to activate your account.'
#    @agent.reload
#    assert_not_nil @agent.activation_digest
#    assert_redirected_to root_url
#  end

#  test "expired token" do
#    get new_password_reset_path
#    post password_resets_path, password_reset: { email: @agent.email }
#
#    @agent = assigns(:agent)
#    @agent.update_attribute(:reset_sent_at, 3.hours.ago)
#    patch password_reset_path(@agent.reset_token),
#          email: @agent.email,
#          agent: { password:              "foobar",
#          password_confirmation: "foobar" }
#    assert_response :redirect
#    follow_redirect!
#    assert_match /Password reset has expired/i, response.body
#  end

end

