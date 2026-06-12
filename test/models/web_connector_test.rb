require "test_helper"

class WebConnectorTest < ActiveSupport::TestCase
  test "accepts valid https URL" do
    connector = web_connector(urls: [ "https://docs.example.com/start" ])

    assert connector.valid?
  end

  test "rejects localhost private and unsafe URLs" do
    [
      "http://localhost:3000/start",
      "http://127.0.0.1/start",
      "http://10.0.0.1/start",
      "file:///etc/passwd"
    ].each do |url|
      connector = web_connector(urls: [ url ])

      assert_not connector.valid?, "#{url} should be rejected"
    end
  end

  test "normalizes URLs" do
    connector = web_connector(urls: [ "HTTPS://Docs.Example.com/start#intro" ])

    connector.valid?

    assert_equal [ "https://docs.example.com/start" ], connector.urls
  end

  test "applies crawl defaults" do
    connector = web_connector

    connector.valid?

    assert_equal 1, connector.max_depth
    assert_equal 20, connector.max_pages
    assert_equal 1, connector.delay_seconds
    assert_equal 2, connector.concurrency
    assert_equal false, connector.allow_pdfs
  end

  private

  def web_connector(**attributes)
    WebConnector.new({
      user: users(:regular),
      name: "Docs",
      urls: [ "https://docs.example.com/start" ]
    }.merge(attributes))
  end
end
