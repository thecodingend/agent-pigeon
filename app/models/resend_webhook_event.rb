class ResendWebhookEvent < ApplicationRecord
  enum :status, { pending: 0, processed: 1, ignored: 2, failed: 3 }, default: :pending

  validates :svix_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :payload, presence: true
end
