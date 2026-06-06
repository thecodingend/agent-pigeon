class ApiConnector < ApplicationRecord
  DEFAULT_TIMEOUT_SECONDS = 10
  MAX_TIMEOUT_SECONDS = 30
  DEFAULT_MAX_RESPONSE_BYTES = 1.megabyte
  MAX_RESPONSE_BYTES = 5.megabytes

  belongs_to :user

  has_many :agent_api_connectors, dependent: :destroy
  has_many :agents, through: :agent_api_connectors

  enum :http_method, { get: 0, post: 1 }, default: :get

  encrypts :auth_token

  attr_accessor :request_example_text, :response_example_text, :query_schema_text, :response_schema_text

  after_initialize :apply_defaults, if: :new_record?

  validates :name, presence: true
  validates :base_url, presence: true
  validates :http_method, inclusion: { in: %w[get], message: "must be GET" }
  validates :auth_type, inclusion: { in: %w[bearer] }
  validates :enabled, inclusion: { in: [ true, false ] }
  validates :timeout_seconds, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_TIMEOUT_SECONDS }
  validates :max_response_bytes, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_RESPONSE_BYTES }

  validate :parse_json_examples
  validate :validate_tool_schemas
  validate :base_url_allowed

  def serializable_hash(options = nil)
    super({ except: [ :auth_token ] }.deep_merge(options || {}))
  end

  private

  def apply_defaults
    self.http_method ||= "get"
    self.auth_type = "bearer" if auth_type.blank?
    self.enabled = true if enabled.nil?
    self.timeout_seconds ||= DEFAULT_TIMEOUT_SECONDS
    self.max_response_bytes ||= DEFAULT_MAX_RESPONSE_BYTES
    self.query_schema ||= {}
    self.response_schema ||= {}
  end

  def parse_json_examples
    parse_json_example(:request_example, request_example_text)
    parse_json_example(:response_example, response_example_text)
    parse_json_example(:query_schema, query_schema_text)
    parse_json_example(:response_schema, response_schema_text)
  end

  def parse_json_example(field, text)
    return if text.nil?
    self[field] = text.blank? ? {} : JSON.parse(text)
  rescue JSON::ParserError
    errors.add(field, "must be valid JSON")
  end

  def validate_tool_schemas
    validate_schema(:query_schema, query_schema)
    validate_schema(:response_schema, response_schema)
  end

  def validate_schema(field, schema)
    JsonSchemaValidator.schema_errors(schema).each do |message|
      errors.add(field, message)
    end
  end

  def base_url_allowed
    errors.add(:base_url, "is not allowed") unless UrlPolicy.allowed?(base_url)
  end
end
