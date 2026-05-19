require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "google auth creates a confirmed regular user" do
    user = User.from_google(google_auth(email: "google@example.com", uid: "google-123"))

    assert user.persisted?
    assert user.confirmed?
    assert user.regular?
    assert_equal "google@example.com", user.email
    assert_equal "google_oauth2", user.provider
    assert_equal "google-123", user.uid
  end

  test "google auth links an existing email account" do
    user = users(:regular)

    linked_user = User.from_google(google_auth(email: user.email, uid: "linked-google-123"))

    assert_equal user, linked_user
    assert_equal "google_oauth2", linked_user.provider
    assert_equal "linked-google-123", linked_user.uid
  end

  private

  def google_auth(email:, uid:)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email },
    )
  end
end
