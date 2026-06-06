require "test_helper"

class ApiToolExecutorTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :calls

    def initialize(result)
      @result = result
      @calls = []
    end

    def get(url, token:, timeout_seconds:, max_response_bytes:)
      @calls << { url: url, token: token, timeout_seconds: timeout_seconds, max_response_bytes: max_response_bytes }
      @result
    end
  end

  test "rejects non GET connector" do
    connector = api_connector
    connector.http_method = :post

    result = ApiToolExecutor.call(connector, {}, client: FakeClient.new(ok: true))

    assert_not result[:ok]
    assert_equal "Only GET API connectors can be called", result[:error]
  end

  test "validates query params" do
    connector = api_connector(query_schema: {
      "type" => "object",
      "properties" => { "query" => { "type" => "string" } },
      "required" => [ "query" ]
    })

    result = ApiToolExecutor.call(connector, {}, client: FakeClient.new(ok: true))

    assert_not result[:ok]
    assert_includes result[:error], "Query params failed schema validation"
  end

  test "calls bearer client with safe URL and token" do
    client = FakeClient.new(ok: true, status: 200, headers: {}, body: { "id" => "cus_1" }, error: nil)
    connector = api_connector(base_url: "https://api.example.com/customers?active=true")

    result = ApiToolExecutor.call(connector, { "query" => "ada" }, client: client)

    assert result[:ok]
    assert_equal "https://api.example.com/customers?active=true&query=ada", client.calls.first[:url]
    assert_equal "secret-token", client.calls.first[:token]
    assert_equal 10, client.calls.first[:timeout_seconds]
    assert_equal 1.megabyte, client.calls.first[:max_response_bytes]
  end

  test "validates response schema" do
    client = FakeClient.new(ok: true, status: 200, headers: {}, body: { "name" => "Ada" }, error: nil)
    connector = api_connector(response_schema: {
      "type" => "object",
      "properties" => { "id" => { "type" => "string" } },
      "required" => [ "id" ]
    })

    result = ApiToolExecutor.call(connector, {}, client: client)

    assert_not result[:ok]
    assert_includes result[:error], "Response failed schema validation"
  end

  test "returns redacted normalized result" do
    client = FakeClient.new(ok: true, status: 200, headers: { "authorization" => "Bearer abc" }, body: { "api_key" => "secret" }, error: nil)

    result = ApiToolExecutor.call(api_connector, {}, client: client)

    assert result[:ok]
    assert_equal ToolResultRedactor::REDACTION, result[:headers]["authorization"]
    assert_equal ToolResultRedactor::REDACTION, result[:body]["api_key"]
  end

  private

  def api_connector(**attributes)
    ApiConnector.new({
      user: users(:regular),
      name: "Customers",
      base_url: "https://api.example.com/customers",
      auth_token: "secret-token"
    }.merge(attributes))
  end
end
