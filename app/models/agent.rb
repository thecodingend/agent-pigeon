class Agent < ApplicationRecord
  belongs_to :user

  has_many :allowlist_entries, dependent: :destroy

  has_many :agent_api_connectors, dependent: :destroy
  has_many :api_connectors, through: :agent_api_connectors

  has_many :agent_web_connectors, dependent: :destroy
  has_many :web_connectors, through: :agent_web_connectors

  has_many :email_threads, -> { order(last_activity_at: :desc) }, dependent: :destroy
  has_one :email_connection, dependent: :destroy
  has_one :sending_domain, through: :email_connection

  enum :status, { active: 0, paused: 1 }, default: :active
  enum :inbox_policy, { open: 0, allowlist: 1 }, default: :open

  validates :name, presence: true

  def email_address
    email_connection&.support_address
  end
end
