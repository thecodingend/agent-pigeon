require "test_helper"

class ResendWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "stores signed webhook event" do
    payload = { type: "email.received", data: { to: [ "ec_test@inbound.example.test" ] } }.to_json

    with_webhook_verifier(true) do
      post "/webhooks/resend",
        params: payload,
        headers: svix_headers.merge("CONTENT_TYPE" => "application/json")
    end

    assert_response :ok
    assert_equal 1, ResendWebhookEvent.count
    assert_equal "email.received", ResendWebhookEvent.first.event_type
  end

  test "returns success for duplicate signed webhook event" do
    ResendWebhookEvent.create!(
      svix_id: "msg_duplicate",
      event_type: "email.received",
      payload: { "type" => "email.received" }
    )
    payload = { type: "email.received", data: { to: [] } }.to_json

    with_webhook_verifier(true) do
      post "/webhooks/resend",
        params: payload,
        headers: svix_headers("msg_duplicate").merge("CONTENT_TYPE" => "application/json")
    end

    assert_response :ok
    assert_equal 1, ResendWebhookEvent.count
  end

  test "rejects unsigned webhook event" do
    with_webhook_verifier(->(*) { raise "bad signature" }) do
      post "/webhooks/resend",
        params: { type: "email.received" }.to_json,
        headers: svix_headers.merge("CONTENT_TYPE" => "application/json")
    end

    assert_response :unauthorized
    assert_equal 0, ResendWebhookEvent.count
  end

  private

  def svix_headers(id = "msg_test")
    {
      "svix-id" => id,
      "svix-timestamp" => Time.current.to_i.to_s,
      "svix-signature" => "v1,test"
    }
  end

  def with_webhook_verifier(result)
    original = Resend::Webhooks.method(:verify)
    Resend::Webhooks.define_singleton_method(:verify) do |*args|
      result.respond_to?(:call) ? result.call(*args) : result
    end
    yield
  ensure
    Resend::Webhooks.define_singleton_method(:verify, original)
  end
end
