require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "context policy defaults to thread history" do
    domain = Domain.create!(user: users(:regular), hostname: "agent-default.example", status: :verified)
    agent = Agent.create!(user: users(:regular), domain: domain, name: "Support", local_part: "support")

    assert_predicate agent, :thread_history?
    assert_equal "thread_history", agent.context_policy
  end

  test "context policy can be last message only" do
    domain = Domain.create!(user: users(:regular), hostname: "agent-context.example", status: :verified)
    agent = Agent.create!(
      user: users(:regular),
      domain: domain,
      name: "Support",
      local_part: "support",
      context_policy: :last_message_only,
    )

    assert_predicate agent, :last_message_only?
    assert_equal "last_message_only", agent.context_policy
  end
end
