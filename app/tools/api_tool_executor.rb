require "uri"

class ApiToolExecutor
  def self.call(connector, params = {}, client: BearerAuthClient.new)
    new(connector, client: client).call(params)
  end

  def initialize(connector, client: BearerAuthClient.new, validator: JsonSchemaValidator.new, redactor: ToolResultRedactor.new, url_policy: UrlPolicy.new)
    @connector = connector
    @client = client
    @validator = validator
    @redactor = redactor
    @url_policy = url_policy
  end

  def call(params = {})
    return result("Connector is disabled") unless connector.enabled?
    return result("Only GET API connectors can be called") unless connector.get?
    return result("Only bearer authentication is supported") unless connector.auth_type == "bearer"
    return result("Bearer token is missing") if connector.auth_token.blank?

    query_params = params.to_h
    query_validation = validate_schema(connector.query_schema, query_params)
    return result("Query params failed schema validation: #{query_validation.errors.join(', ')}") unless query_validation.valid?

    url = build_url(query_params)
    return result("Connector URL is not allowed") unless url

    response = client.get(
      url,
      token: connector.auth_token,
      timeout_seconds: connector.timeout_seconds,
      max_response_bytes: connector.max_response_bytes
    )

    return redact_response(response) unless response[:ok]

    response_validation = validate_schema(connector.response_schema, response[:body])
    return redact_response(response) if response_validation.valid?

    redact_response(response.merge(ok: false, error: "Response failed schema validation: #{response_validation.errors.join(', ')}"))
  end

  private

  attr_reader :connector, :client

  def validate_schema(schema, value)
    return JsonSchemaValidator::Result.new([]) if schema.blank?

    @validator.validate(schema, value)
  end

  def build_url(params)
    normalized = @url_policy.normalize(connector.base_url)
    return nil unless normalized

    uri = URI.parse(normalized)
    query_pairs = URI.decode_www_form(uri.query.to_s)
    params.each do |key, value|
      Array(value).each { |item| query_pairs << [ key.to_s, item.to_s ] }
    end
    uri.query = query_pairs.empty? ? nil : URI.encode_www_form(query_pairs)
    uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  def result(error)
    {
      ok: false,
      status: nil,
      headers: {},
      body: nil,
      error: @redactor.redact(error)
    }
  end

  def redact_response(response)
    response.merge(
      headers: @redactor.redact(response[:headers]),
      body: @redactor.redact(response[:body]),
      error: @redactor.redact(response[:error])
    )
  end
end
