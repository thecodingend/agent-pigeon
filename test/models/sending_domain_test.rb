require "test_helper"

class SendingDomainTest < ActiveSupport::TestCase
  test "hostnames are globally unique" do
    SendingDomain.create!(
      user: users(:regular),
      hostname: "example.com",
      resend_domain_id: "domain_1"
    )

    domain = SendingDomain.new(
      user: users(:admin),
      hostname: "EXAMPLE.com",
      resend_domain_id: "domain_2"
    )

    assert_not domain.valid?
    assert_includes domain.errors[:hostname], "has already been taken"
  end
end
