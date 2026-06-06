require "test_helper"

class SimpleFetchProviderTest < ActiveSupport::TestCase
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
      @responses.shift
    end
  end

  test "rejects unsafe URLs" do
    transport = FakeTransport.new
    result = SimpleFetchProvider.new(transport: transport).fetch("http://127.0.0.1")

    assert_not result[:ok]
    assert_equal "URL is not allowed", result[:error]
    assert_empty transport.requests
  end

  test "fetches allowed URLs and extracts title and text" do
    response = FakeResponse.new(
      "200",
      "<html><head><title>Docs</title></head><body><script>bad()</script><main>Hello docs</main></body></html>",
      { "content-type" => "text/html" }
    )

    result = SimpleFetchProvider.new(transport: FakeTransport.new(response)).fetch("https://docs.example.com/start")

    assert result[:ok]
    assert_equal "Docs", result[:title]
    assert_equal "Hello docs", result[:text]
  end

  test "caps and redacts response text" do
    response = FakeResponse.new("200", "Bearer abc123 password=secret trailing", { "content-type" => "text/plain" })

    result = SimpleFetchProvider.new(transport: FakeTransport.new(response)).fetch("https://docs.example.com/start", max_response_bytes: 29)

    assert_equal "Bearer [REDACTED] password=[REDACTED]", result[:text]
  end
end
