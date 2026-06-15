class SendingDomain < ApplicationRecord
  RETURN_PATH_LABEL = "agentpigeon"

  belongs_to :user
  has_many :email_connections, dependent: :restrict_with_error

  enum :status, { pending: 0, checking: 1, verified: 2, failed: 3 }, default: :pending

  validates :hostname, presence: true, uniqueness: { case_sensitive: false }
  validates :resend_domain_id, presence: true, uniqueness: true
  validates :return_path_label, presence: true

  before_validation do
    self.hostname = hostname.to_s.downcase.strip
    self.return_path_label = return_path_label.presence || RETURN_PATH_LABEL
  end

  def self.status_from_resend(status)
    {
      "not_started" => "pending",
      "pending" => "pending",
      "temporary_failure" => "checking",
      "partially_verified" => "checking",
      "partially_failed" => "failed",
      "verified" => "verified",
      "failed" => "failed"
    }.fetch(status)
  end
end
