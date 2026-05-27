class ApiConnector < ApplicationRecord
  belongs_to :user

  has_many :agent_api_connectors, dependent: :destroy
  has_many :agents, through: :agent_api_connectors

  enum :http_method, { get: 0, post: 1 }, default: :get

  encrypts :auth_token

  attr_accessor :request_example_text, :response_example_text

  validates :name, presence: true
  validates :base_url, presence: true
  validate :parse_json_examples

  private

  def parse_json_examples
    parse_json_example(:request_example, request_example_text)
    parse_json_example(:response_example, response_example_text)
  end

  def parse_json_example(field, text)
    return if text.nil?
    self[field] = text.blank? ? {} : JSON.parse(text)
  rescue JSON::ParserError
    errors.add(field, "must be valid JSON")
  end
end
