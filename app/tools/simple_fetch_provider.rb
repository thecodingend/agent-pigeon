require "net/http"
require "nokogiri"
require "uri"

class SimpleFetchProvider
  DEFAULT_TIMEOUT_SECONDS = 10
  DEFAULT_MAX_RESPONSE_BYTES = 512.kilobytes
  REDIRECT_STATUSES = [ 301, 302, 303, 307, 308 ].freeze
  MAX_REDIRECTS = 3

  def initialize(url_policy: UrlPolicy.new, redactor: ToolResultRedactor.new, transport: NetHttpTransport.new)
    @url_policy = url_policy
    @redactor = redactor
    @transport = transport
  end

  def fetch(url, timeout_seconds: DEFAULT_TIMEOUT_SECONDS, max_response_bytes: DEFAULT_MAX_RESPONSE_BYTES)
    normalized_url = @url_policy.normalize(url)
    return result(error: "URL is not allowed") unless normalized_url

    perform_fetch(URI.parse(normalized_url), timeout_seconds.to_i, max_response_bytes.to_i, MAX_REDIRECTS)
  end

  private

  def perform_fetch(uri, timeout_seconds, max_response_bytes, redirects_remaining)
    request = Net::HTTP::Get.new(uri)
    response = @transport.request(uri, request, timeout: timeout_seconds)
    status = response.code.to_i
    headers = normalize_headers(response)

    if REDIRECT_STATUSES.include?(status)
      return result(status: status, headers: headers, error: "Too many redirects") if redirects_remaining <= 0

      redirect_url = redirect_url(uri, headers)
      normalized_redirect = redirect_url && @url_policy.normalize(redirect_url)
      return result(status: status, headers: headers, error: "Redirect URL is not allowed") unless normalized_redirect

      return perform_fetch(URI.parse(normalized_redirect), timeout_seconds, max_response_bytes, redirects_remaining - 1)
    end

    body = response.body.to_s.byteslice(0, max_response_bytes).to_s.scrub
    parsed = parse_body(body, headers)

    result(
      ok: status.between?(200, 299),
      status: status,
      headers: headers,
      title: parsed[:title],
      text: parsed[:text],
      error: status.between?(200, 299) ? nil : "HTTP #{status}"
    )
  rescue => error
    result(error: error.message)
  end

  def parse_body(body, headers)
    content_type = headers["content-type"].to_s
    return plain_text(body) unless content_type.include?("html") || body.include?("<html")

    document = Nokogiri::HTML(body)
    document.css("script, style, noscript").remove
    title = document.at_css("title")&.text.to_s.strip.presence
    text = document.at_css("body")&.text.to_s.gsub(/\s+/, " ").strip
    { title: title, text: text }
  end

  def plain_text(body)
    { title: nil, text: body.gsub(/\s+/, " ").strip }
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

  def result(ok: false, status: nil, headers: {}, title: nil, text: nil, error: nil)
    {
      ok: ok,
      status: status,
      headers: @redactor.redact(headers),
      title: @redactor.redact(title),
      text: @redactor.redact(text),
      error: @redactor.redact(error)
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
