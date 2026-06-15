require "test_helper"

class ProcessResendWebhookEventJobTest < ActiveJob::TestCase
  test "domain updated event updates sending domain" do
    domain = SendingDomain.create!(
      user: users(:regular),
      hostname: "example.com",
      resend_domain_id: "domain_123"
    )
    event = ResendWebhookEvent.create!(
      svix_id: "msg_domain",
      event_type: "domain.updated",
      payload: {
        "type" => "domain.updated",
        "data" => {
          "id" => "domain_123",
          "status" => "verified",
          "records" => [ { "type" => "TXT", "name" => "resend._domainkey", "value" => "key", "status" => "verified" } ]
        }
      }
    )

    ProcessResendWebhookEventJob.perform_now(event)

    assert_equal "verified", domain.reload.status
    assert domain.verified_at
    assert_equal "processed", event.reload.status
  end

  test "domain updated event handles documented non-final resend statuses" do
    {
      "temporary_failure" => "checking",
      "partially_verified" => "checking",
      "partially_failed" => "failed"
    }.each do |resend_status, expected_status|
      assert_domain_status_from_resend resend_status, expected_status
    end
  end

  test "email received event marks forwarding ready" do
    connection = create_connection
    event = ResendWebhookEvent.create!(
      svix_id: "msg_received",
      event_type: "email.received",
      payload: {
        "type" => "email.received",
        "data" => { "to" => [ connection.forwarding_address ] }
      }
    )

    ProcessResendWebhookEventJob.perform_now(event)

    assert_equal "ready", connection.reload.forwarding_status
    assert connection.forwarding_verified_at
    assert_equal "processed", event.reload.status
  end

  test "unsupported event is ignored" do
    event = ResendWebhookEvent.create!(
      svix_id: "msg_ignored",
      event_type: "email.sent",
      payload: { "type" => "email.sent" }
    )

    ProcessResendWebhookEventJob.perform_now(event)

    assert_equal "ignored", event.reload.status
  end

  private

  def assert_domain_status_from_resend(resend_status, expected_status)
    domain = SendingDomain.create!(
      user: users(:regular),
      hostname: "#{resend_status.tr("_", "-")}.example.com",
      resend_domain_id: "domain_#{resend_status}"
    )
    event = ResendWebhookEvent.create!(
      svix_id: "msg_#{resend_status}",
      event_type: "domain.updated",
      payload: {
        "type" => "domain.updated",
        "data" => {
          "id" => domain.resend_domain_id,
          "status" => resend_status,
          "records" => [ { "type" => "MX", "name" => "send", "value" => "feedback-smtp.us-east-1.amazonses.com", "status" => resend_status } ]
        }
      }
    )

    ProcessResendWebhookEventJob.perform_now(event)

    assert_equal expected_status, domain.reload.status
    assert_nil domain.verified_at
    assert_equal "processed", event.reload.status
  end

  def create_connection
    domain = SendingDomain.create!(
      user: users(:regular),
      hostname: "example.com",
      resend_domain_id: "domain_connection"
    )
    agent = Agent.create!(user: users(:regular), name: "Support")
    EmailConnection.create!(
      agent: agent,
      sending_domain: domain,
      support_address: "support@example.com"
    )
  end
end
