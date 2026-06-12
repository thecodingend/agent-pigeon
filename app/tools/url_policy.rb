require "ipaddr"
require "uri"

class UrlPolicy
  BLOCKED_PATH_PREFIXES = %w[
    /admin
    /account
    /login
    /logout
    /signup
    /password
    /oauth
    /checkout
    /cart
  ].freeze

  PRIVATE_RANGES = [
    IPAddr.new("0.0.0.0/8"),
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("127.0.0.0/8"),
    IPAddr.new("169.254.0.0/16"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16"),
    IPAddr.new("::1/128"),
    IPAddr.new("fc00::/7"),
    IPAddr.new("fe80::/10")
  ].freeze

  def self.normalize(url)
    new.normalize(url)
  end

  def self.allowed?(url)
    new.allowed?(url)
  end

  def self.same_host?(base_url, candidate_url)
    new.same_host?(base_url, candidate_url)
  end

  def normalize(url)
    uri = parse(url)
    return nil unless uri

    uri.scheme = uri.scheme.downcase
    uri.host = uri.host.downcase
    uri.path = "/" if uri.path.blank?
    uri.fragment = nil

    normalized = uri.to_s
    allowed?(normalized) ? normalized : nil
  end

  def allowed?(url)
    uri = parse(url)
    return false unless uri
    return false unless %w[http https].include?(uri.scheme)
    return false if unsafe_host?(uri.host)
    return false if blocked_path?(uri.path)

    true
  end

  def same_host?(base_url, candidate_url)
    base = parse(base_url)
    candidate = parse(candidate_url)
    return false unless base && candidate

    base.host.downcase == candidate.host.downcase
  end

  private

  def parse(url)
    uri = URI.parse(url.to_s.strip)
    return nil unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri
  rescue URI::InvalidURIError
    nil
  end

  def unsafe_host?(host)
    normalized = host.to_s.downcase
    return true if normalized == "localhost" || normalized.end_with?(".localhost")

    ip_address = IPAddr.new(normalized)
    PRIVATE_RANGES.any? { |range| range.include?(ip_address) }
  rescue IPAddr::InvalidAddressError
    false
  end

  def blocked_path?(path)
    normalized = path.to_s.downcase
    BLOCKED_PATH_PREFIXES.any? do |prefix|
      normalized == prefix || normalized.start_with?("#{prefix}/")
    end
  end
end
