class ResendWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    raw_body = request.raw_post
    headers = {
      svix_id: request.headers["svix-id"],
      svix_timestamp: request.headers["svix-timestamp"],
      svix_signature: request.headers["svix-signature"]
    }

    begin
      Resend::Webhooks.verify(
        payload: raw_body,
        headers: headers,
        webhook_secret: Rails.application.config.x.resend.webhook_secret
      )
    rescue StandardError
      head :unauthorized
      return
    end

    payload = JSON.parse(raw_body)
    if ResendWebhookEvent.exists?(svix_id: headers.fetch(:svix_id))
      head :ok
      return
    end

    event = ResendWebhookEvent.create!(
      svix_id: headers.fetch(:svix_id),
      event_type: payload.fetch("type"),
      payload: payload
    )

    ProcessResendWebhookEventJob.perform_later(event)
    head :ok
  rescue JSON::ParserError, KeyError
    head :bad_request
  rescue ActiveRecord::RecordNotUnique
    head :ok
  end
end
