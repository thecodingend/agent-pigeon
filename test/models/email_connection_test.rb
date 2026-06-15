require "test_helper"

class EmailConnectionTest < ActiveSupport::TestCase
  test "rejects personal provider domains" do
    connection = build_connection(support_address: "support@gmail.com")

    assert_not connection.valid?
    assert_includes connection.errors[:support_address], "Use an email address on a domain you control, such as support@yourcompany.com."
  end

  test "requires support address to match sending domain" do
    connection = build_connection(support_address: "support@other.com")

    assert_not connection.valid?
    assert_includes connection.errors[:support_address], "must be on example.com"
  end

  test "does not allow changing the support address domain" do
    connection = build_connection
    connection.save!

    connection.support_address = "support@other.com"

    assert_not connection.valid?
    assert_includes connection.errors[:support_address], "domain cannot be changed"
  end

  test "requires agent and sending domain to share user" do
    domain = SendingDomain.create!(
      user: users(:admin),
      hostname: "example.com",
      resend_domain_id: "domain_admin"
    )
    agent = Agent.create!(user: users(:regular), name: "Support")
    connection = EmailConnection.new(
      agent: agent,
      sending_domain: domain,
      support_address: "support@example.com"
    )

    assert_not connection.valid?
    assert_includes connection.errors[:sending_domain], "must belong to the agent owner"
  end

  private

  def build_connection(support_address: "support@example.com")
    domain = SendingDomain.create!(
      user: users(:regular),
      hostname: "example.com",
      resend_domain_id: "domain_#{SecureRandom.hex(4)}"
    )
    agent = Agent.create!(user: users(:regular), name: "Support #{SecureRandom.hex(4)}")

    EmailConnection.new(
      agent: agent,
      sending_domain: domain,
      support_address: support_address
    )
  end
end
