class Domain < ApplicationRecord
  belongs_to :user
  has_many :agents, dependent: :destroy

  enum :status, { pending: 0, verifying: 1, verified: 2, failed: 3 }, default: :pending

  validates :hostname, presence: true, uniqueness: { case_sensitive: false }

  before_validation { self.hostname = hostname.to_s.downcase.strip }
end
