require "test_helper"

class ToolResultRedactorTest < ActiveSupport::TestCase
  test "redacts authorization headers" do
    redacted = ToolResultRedactor.redact({ "Authorization" => "Bearer abc123" })

    assert_equal ToolResultRedactor::REDACTION, redacted["Authorization"]
  end

  test "redacts bearer strings" do
    redacted = ToolResultRedactor.redact("Authorization: Bearer abc123")

    assert_equal "Authorization: Bearer [REDACTED]", redacted
  end

  test "redacts cookies secrets passwords and api keys" do
    value = {
      "Cookie" => "session=abc",
      "set-cookie" => "session=abc",
      "password" => "secret",
      "api_key" => "key",
      "body" => "password=hunter2&secret=value&api_key=key"
    }

    redacted = ToolResultRedactor.redact(value)

    assert_equal ToolResultRedactor::REDACTION, redacted["Cookie"]
    assert_equal ToolResultRedactor::REDACTION, redacted["set-cookie"]
    assert_equal ToolResultRedactor::REDACTION, redacted["password"]
    assert_equal ToolResultRedactor::REDACTION, redacted["api_key"]
    assert_includes redacted["body"], "password=[REDACTED]"
    assert_includes redacted["body"], "secret=[REDACTED]"
    assert_includes redacted["body"], "api_key=[REDACTED]"
  end
end
