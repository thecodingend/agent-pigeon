class Agent < ApplicationRecord
  belongs_to :user
  belongs_to :domain

  has_many :allowlist_entries, dependent: :destroy

  has_many :agent_api_connectors, dependent: :destroy
  has_many :api_connectors, through: :agent_api_connectors

  has_many :agent_web_connectors, dependent: :destroy
  has_many :web_connectors, through: :agent_web_connectors

  has_many :email_threads, -> { order(last_activity_at: :desc) }, dependent: :destroy

  enum :status, { active: 0, paused: 1 }, default: :active
  enum :inbox_policy, { open: 0, allowlist: 1 }, default: :open

  validates :name, presence: true
  validates :local_part,
    presence: true,
    format: { with: /\A[a-z0-9._-]+\z/, message: "may contain only lowercase letters, numbers, dots, dashes, and underscores" },
    uniqueness: { scope: :domain_id }

  before_validation { self.local_part = local_part.to_s.downcase.strip }

  def email_address
    "#{local_part}@#{domain.hostname}"
  end
end
