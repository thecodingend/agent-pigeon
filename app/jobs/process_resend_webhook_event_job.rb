class ProcessResendWebhookEventJob < ApplicationJob
  queue_as :default

  def perform(event)
    return if event.processed? || event.ignored?

    case event.event_type
    when "domain.updated"
      process_domain_updated(event)
    when "email.received"
      process_email_received(event)
    else
      event.update!(status: :ignored, processed_at: Time.current)
    end
  rescue KeyError => error
    event.update!(status: :failed, error_message: "Missing required webhook field: #{error.key}", processed_at: Time.current)
  rescue TypeError => error
    event.update!(status: :failed, error_message: error.message, processed_at: Time.current)
  rescue StandardError => error
    event.update!(status: :failed, error_message: error.message, processed_at: Time.current)
    raise
  end

  private

  def process_domain_updated(event)
    data = event.payload.fetch("data")
    resend_domain_id = data.fetch("id")
    status = SendingDomain.status_from_resend(data.fetch("status"))
    records = data.fetch("records")

    domain = SendingDomain.find_by(resend_domain_id: resend_domain_id)
    unless domain
      event.update!(status: :ignored, processed_at: Time.current)
      return
    end

    domain.update!(
      status: status,
      dns_records: records,
      verified_at: status == "verified" ? Time.current : nil
    )
    event.update!(status: :processed, processed_at: Time.current)
  end

  def process_email_received(event)
    data = event.payload.fetch("data")
    recipients = data.fetch("to")
    raise TypeError, "email.received data.to must be an array" unless recipients.is_a?(Array)

    connection = EmailConnection.find_by(forwarding_address: recipients.map { |email| email.to_s.downcase.strip })
    unless connection
      event.update!(status: :ignored, processed_at: Time.current)
      return
    end

    connection.update!(forwarding_status: :ready, forwarding_verified_at: Time.current)
    # Later email handling starts here: fetch the full email from Resend and create EmailThread/EmailMessage.
    event.update!(status: :processed, processed_at: Time.current)
  end
end
