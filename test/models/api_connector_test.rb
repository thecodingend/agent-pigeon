require "test_helper"

class ApiConnectorTest < ActiveSupport::TestCase
  test "accepts get connectors" do
    connector = api_connector

    assert connector.valid?
    assert_predicate connector, :get?
  end

  test "rejects post connectors" do
    connector = api_connector(http_method: :post)

    assert_not connector.valid?
    assert_includes connector.errors[:http_method], "must be GET"
  end

  test "validates schema JSON text" do
    connector = api_connector(query_schema_text: "{bad json")

    assert_not connector.valid?
    assert_includes connector.errors[:query_schema], "must be valid JSON"
  end

  test "validates schema shape" do
    connector = api_connector(query_schema: { "type" => "object", "properties" => { "query" => { "type" => "wat" } } })

    assert_not connector.valid?
    assert connector.errors[:query_schema].any? { |message| message.include?("$.properties.query.type") }
  end

  test "does not expose auth token in serialization" do
    connector = api_connector(auth_token: "secret-token")

    assert_not_includes connector.serializable_hash.keys, "auth_token"
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
