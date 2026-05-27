require "test_helper"

class DomainTest < ActiveSupport::TestCase
  test "hostnames are globally unique" do
    Domain.create!(user: users(:regular), hostname: "example.com")

    domain = Domain.new(user: users(:admin), hostname: "EXAMPLE.com")

    assert_not domain.valid?
    assert_includes domain.errors[:hostname], "has already been taken"
  end
end
