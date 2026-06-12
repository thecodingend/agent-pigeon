require "test_helper"

class BearerAuthClientTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:code, :body, :headers) do
    def to_hash
      headers.transform_values { |value| Array(value) }
    end
  end

  class FakeTransport
    attr_reader :requests

    def initialize(*responses)
      @responses = responses
      @requests = []
    end

    def request(uri, request, timeout:)
      @requests << { uri: uri, request: request, timeout: timeout }
      response = @responses.shift
      raise response if response.is_a?(Exception)

      response
    end
  end

  test "only performs GET" do
    transport = FakeTransport.new
    result = BearerAuthClient.new(transport: transport).request(method: "POST", url: "https://api.example.com", token: "secret")

    assert_not result[:ok]
    assert_equal "Only GET requests are supported", result[:error]
    assert_empty transport.requests
  end

  test "injects authorization internally" do
    transport = FakeTransport.new(FakeResponse.new("200", "{}", { "content-type" => "application/json" }))

    BearerAuthClient.new(transport: transport).get("https://api.example.com/customers", token: "secret")

    assert_equal "Bearer secret", transport.requests.first[:request]["Authorization"]
  end

  test "redacts returned headers and JSON body" do
    response = FakeResponse.new(
      "200",
      '{"api_key":"secret","name":"Ada"}',
      { "content-type" => "application/json", "authorization" => "Bearer abc", "set-cookie" => "session=secret" }
    )

    result = BearerAuthClient.new(transport: FakeTransport.new(response)).get("https://api.example.com/customers", token: "secret")

    assert result[:ok]
    assert_equal ToolResultRedactor::REDACTION, result[:headers]["authorization"]
    assert_equal ToolResultRedactor::REDACTION, result[:headers]["set-cookie"]
    assert_equal ToolResultRedactor::REDACTION, result[:body]["api_key"]
    assert_equal "Ada", result[:body]["name"]
  end

  test "caps responses" do
    response = FakeResponse.new("200", "abcdef", { "content-type" => "text/plain" })

    result = BearerAuthClient.new(transport: FakeTransport.new(response)).get("https://api.example.com/data", token: "secret", max_response_bytes: 3)

    assert_equal "abc", result[:body]
  end

  test "rejects unsafe redirects" do
    response = FakeResponse.new("302", "", { "location" => "http://127.0.0.1/admin" })

    result = BearerAuthClient.new(transport: FakeTransport.new(response)).get("https://api.example.com/data", token: "secret")

    assert_not result[:ok]
    assert_equal "Redirect URL is not allowed", result[:error]
  end

  test "redacts exception messages" do
    transport = FakeTransport.new(StandardError.new("failed with Bearer abc123"))

    result = BearerAuthClient.new(transport: transport).get("https://api.example.com/data", token: "secret")

    assert_equal "failed with Bearer [REDACTED]", result[:error]
  end
end
