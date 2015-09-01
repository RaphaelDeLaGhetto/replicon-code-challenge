require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  include Devise::TestHelpers

  def setup
    @request.env["devise.mapping"] = Devise.mappings[:agent]

#    @agent = agents(:archer)
#    @admin = agents(:daniel)
#    @admin.confirm
#    @admin.save
  end

  #
  # current_agent
  #
#  test "current_agent returns right agent when session is nil" do
#    assert_equal @agent, current_agent
#    assert is_logged_in?
#  end
#
#  test "current_agent returns nil when remember digest is wrong" do
#    @agent.update_attribute(:remember_digest, Agent.digest(Agent.new_token))
#    assert_nil current_agent
#  end

  #
  # admin_logged_in
  #
  test "admin_logged_in returns true if the agent is an admin" do
#    sign_in(@admin)
#    puts current_agent.inspect
##    puts @admin.inspect
##    assert @admin.admin
#    assert admin_logged_in?
  end

  test "admin_logged_in returns false if the agent is not an admin" do
#    sign_in @agent
#    assert !admin_logged_in?
  end

#  #
#  # correct_agent
#  #
#  test "correct_agent does nothing if the given agent matches current_agent" do
#    assert_nil correct_agent @agent
#  end
#
#  test "correct_agent does nothing if logged in as admin" do
#    log_in_as(@admin)
#    assert_nil correct_agent @admin
#  end
end
