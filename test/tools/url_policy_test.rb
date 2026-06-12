require "test_helper"

class UrlPolicyTest < ActiveSupport::TestCase
  test "normalizes URLs" do
    assert_equal "https://example.com/path?x=1", UrlPolicy.normalize("HTTPS://Example.com/path?x=1#frag")
  end

  test "rejects localhost" do
    assert_not UrlPolicy.allowed?("http://localhost:3000")
  end

  test "rejects 127 address" do
    assert_not UrlPolicy.allowed?("http://127.0.0.1")
  end

  test "rejects 10 private range" do
    assert_not UrlPolicy.allowed?("http://10.1.2.3")
  end

  test "rejects 172 private range" do
    assert_not UrlPolicy.allowed?("http://172.16.0.1")
    assert_not UrlPolicy.allowed?("http://172.31.255.255")
  end

  test "rejects 192 private range" do
    assert_not UrlPolicy.allowed?("http://192.168.1.5")
  end

  test "rejects link local" do
    assert_not UrlPolicy.allowed?("http://169.254.1.1")
  end

  test "rejects unsafe schemes" do
    %w[file:///tmp/a ftp://example.com javascript:alert(1) data:text/plain,hi].each do |url|
      assert_not UrlPolicy.allowed?(url), "#{url} should be rejected"
    end
  end

  test "blocks risky paths" do
    %w[/admin /account /login /logout /signup /password /oauth /checkout /cart].each do |path|
      assert_not UrlPolicy.allowed?("https://example.com#{path}")
      assert_not UrlPolicy.allowed?("https://example.com#{path}/settings")
    end
  end

  test "checks same host" do
    assert UrlPolicy.same_host?("https://example.com/docs", "https://example.com/pricing")
    assert_not UrlPolicy.same_host?("https://example.com/docs", "https://other.example.com/docs")
  end
end
