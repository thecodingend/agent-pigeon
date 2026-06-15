require "test_helper"

class EmailConnectionsControllerTest < ActionDispatch::IntegrationTest
  test "renders the email connection page before setup" do
    sign_in users(:regular)

    get email_connection_path

    assert_inertia_response
    assert_inertia_component "email_connections/show"
    assert_inertia_props email_connection: nil
  end

  test "creates email connection from support address" do
    sign_in users(:regular)

    with_resend_client(resend_client) do
      post email_connection_path, params: {
        email_connection: { support_address: "Support@Example.com" }
      }
    end

    assert_redirected_to email_connection_path
    connection = users(:regular).email_connection
    assert_equal "support@example.com", connection.support_address
    assert_equal "example.com", connection.sending_domain.hostname
    assert_match(/\Aec_[a-z0-9]+@inbound\.example\.test\z/, connection.forwarding_address)
  end

  test "starts dns check for existing connection" do
    sign_in users(:regular)
    connection = create_connection

    with_resend_client(resend_client) do
      post check_dns_email_connection_path
    end

    assert_redirected_to email_connection_path
    assert_equal "checking", connection.sending_domain.reload.status
  end

  test "dns check does not downgrade verified sending domain" do
    sign_in users(:regular)
    connection = create_connection
    connection.sending_domain.update!(
      status: "verified",
      verified_at: Time.current,
      dns_records: [
        { "type" => "TXT", "name" => "resend._domainkey", "value" => "key", "status" => "verified" }
      ]
    )

    with_resend_client(resend_client) do
      post check_dns_email_connection_path
    end

    assert_redirected_to email_connection_path
    assert_equal "verified", connection.sending_domain.reload.status
    assert_equal [ { "type" => "TXT", "name" => "resend._domainkey", "value" => "key", "status" => "verified" } ], connection.sending_domain.dns_records
    assert connection.sending_domain.verified_at
  end

  private

  def create_connection
    domain = SendingDomain.create!(
      user: users(:regular),
      hostname: "example.com",
      resend_domain_id: "domain_existing"
    )
    agent = Agent.create!(user: users(:regular), name: "Support")
    EmailConnection.create!(
      agent: agent,
      sending_domain: domain,
      support_address: "support@example.com"
    )
  end

  def resend_client
    Class.new do
      def create_or_find_sending_domain(_hostname)
        {
          hostname: "example.com",
          resend_domain_id: "domain_resend",
          status: "pending",
          dns_records: [
            { "type" => "TXT", "name" => "resend._domainkey", "value" => "key", "status" => "pending" }
          ]
        }
      end

      def verify_sending_domain(_resend_domain_id)
        true
      end
    end.new
  end

  def with_resend_client(client)
    original = ResendClient.method(:new)
    ResendClient.define_singleton_method(:new) { client }
    yield
  ensure
    ResendClient.define_singleton_method(:new, original)
  end
end
