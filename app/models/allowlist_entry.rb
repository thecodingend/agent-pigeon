class AllowlistEntry < ApplicationRecord
  belongs_to :agent

  validates :pattern, presence: true, uniqueness: { scope: :agent_id, case_sensitive: false }

  before_validation { self.pattern = pattern.to_s.downcase.strip }
end
