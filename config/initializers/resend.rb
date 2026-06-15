Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)

Rails.application.config.x.resend.receiving_domain =
  Rails.application.credentials.dig(:resend, :receiving_domain)

Rails.application.config.x.resend.webhook_secret =
  Rails.application.credentials.dig(:resend, :webhook_secret)
