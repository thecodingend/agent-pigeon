class EmailMessage < ApplicationRecord
  belongs_to :email_thread, touch: true
  belongs_to :message, optional: true

  enum :direction, { inbound: 0, outbound: 1 }
  enum :provider, { resend: 0 }, default: :resend

  validates :from_email, presence: true

  after_save :bump_thread_activity

  private

  def bump_thread_activity
    timestamp = received_at || delivered_at || created_at
    email_thread.update!(last_activity_at: timestamp) if email_thread.last_activity_at.nil? || timestamp > email_thread.last_activity_at
  end
end
