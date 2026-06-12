require "json"
require "net/http"
require "uri"

class BearerAuthClient
  REDIRECT_STATUSES = [ 301, 302, 303, 307, 308 ].freeze
  DEFAULT_TIMEOUT_SECONDS = 10
  DEFAULT_MAX_RESPONSE_BYTES = 1.megabyte
  MAX_REDIRECTS = 3

  def initialize(url_policy: UrlPolicy.new, redactor: ToolResultRedactor.new, transport: NetHttpTransport.new)
    @url_policy = url_policy
    @redactor = redactor
    @transport = transport
  end

  def get(url, token:, timeout_seconds: DEFAULT_TIMEOUT_SECONDS, max_response_bytes: DEFAULT_MAX_RESPONSE_BYTES, headers: {})
    request(method: "GET", url: url, token: token, timeout_seconds: timeout_seconds, max_response_bytes: max_response_bytes, headers: headers)
  end

  def request(method:, url:, token:, timeout_seconds: DEFAULT_TIMEOUT_SECONDS, max_response_bytes: DEFAULT_MAX_RESPONSE_BYTES, headers: {})
    return error_result("Only GET requests are supported") unless method.to_s.upcase == "GET"

    normalized_url = @url_policy.normalize(url)
    return error_result("URL is not allowed") unless normalized_url

    perform_get(URI.parse(normalized_url), token, timeout_seconds.to_i, max_response_bytes.to_i, headers, MAX_REDIRECTS)
  end

  private

  def perform_get(uri, token, timeout_seconds, max_response_bytes, headers, redirects_remaining)
    request = Net::HTTP::Get.new(uri)
    headers.each { |key, value| request[key.to_s] = value.to_s }
    request["Authorization"] = "Bearer #{token}" if token.present?

    response = @transport.request(uri, request, timeout: timeout_seconds)
    status = response.code.to_i
    response_headers = normalize_headers(response)

    if REDIRECT_STATUSES.include?(status)
      return error_result("Too many redirects", status: status, headers: response_headers) if redirects_remaining <= 0

      redirect_url = redirect_url(uri, response_headers)
      normalized_redirect = redirect_url && @url_policy.normalize(redirect_url)
      return error_result("Redirect URL is not allowed", status: status, headers: response_headers) unless normalized_redirect

      return perform_get(URI.parse(normalized_redirect), token, timeout_seconds, max_response_bytes, headers, redirects_remaining - 1)
    end

    body = cap_body(response.body.to_s, max_response_bytes)
    parsed_body = parse_body(body, response_headers)
    ok = status.between?(200, 299)

    {
      ok: ok,
      status: status,
      headers: @redactor.redact(response_headers),
      body: @redactor.redact(parsed_body),
      error: ok ? nil : "HTTP #{status}"
    }
  rescue => error
    error_result(@redactor.redact(error.message))
  end

  def redirect_url(uri, headers)
    location = headers["location"]
    return nil if location.blank?

    URI.join(uri.to_s, location).to_s
  rescue URI::InvalidURIError
    nil
  end

  def normalize_headers(response)
    response.to_hash.transform_values { |value| Array(value).join(", ") }
  end

  def cap_body(body, max_response_bytes)
    body.byteslice(0, max_response_bytes).to_s.scrub
  end

  def parse_body(body, headers)
    content_type = headers["content-type"].to_s
    return JSON.parse(body) if content_type.include?("json") && body.present?

    body
  rescue JSON::ParserError
    body
  end

  def error_result(message, status: nil, headers: {})
    {
      ok: false,
      status: status,
      headers: @redactor.redact(headers),
      body: nil,
      error: @redactor.redact(message)
    }
  end

  class NetHttpTransport
    def request(uri, request, timeout:)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: timeout, read_timeout: timeout) do |http|
        http.request(request)
      end
    end
  end
end
