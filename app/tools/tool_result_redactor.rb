class ToolResultRedactor
  REDACTION = "[REDACTED]"
  SENSITIVE_KEY = /\A(authorization|cookie|set-cookie|password|secret|token|api[_-]?key|x-api-key)\z/i
  BEARER_TOKEN = /Bearer\s+[A-Za-z0-9._~+\/=-]+/i
  SECRET_ASSIGNMENT = /\b(password|secret|api[_-]?key|token|cookie)=([^&\s]+)/i

  def self.redact(value)
    new.redact(value)
  end

  def redact(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, child), redacted|
        redacted[key] = sensitive_key?(key) ? REDACTION : redact(child)
      end
    when Array
      value.map { |child| redact(child) }
    when String
      redact_string(value)
    else
      value
    end
  end

  private

  def sensitive_key?(key)
    key.to_s.match?(SENSITIVE_KEY)
  end

  def redact_string(value)
    value
      .gsub(BEARER_TOKEN, "Bearer #{REDACTION}")
      .gsub(SECRET_ASSIGNMENT) { "#{$1}=#{REDACTION}" }
  end
end
