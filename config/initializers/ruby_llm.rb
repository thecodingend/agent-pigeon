RubyLLM.configure do |config|
  # config.default_model = "gpt-5-nano"

  config.openrouter_api_base = Rails.application.credentials.dig(:openrouter, :base_url)
  config.openrouter_api_key = Rails.application.credentials.dig(:openrouter, :api_key)

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
