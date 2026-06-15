ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "base64"
require "rails/test_help"
require "inertia_rails/minitest"
require "securerandom"

Rails.application.config.x.resend.receiving_domain = "inbound.example.test"
Rails.application.config.x.resend.webhook_secret = "whsec_#{Base64.strict_encode64("test-secret")}"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
