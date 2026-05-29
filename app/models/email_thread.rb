class EmailThread < ApplicationRecord
  belongs_to :agent, counter_cache: true
  has_one :chat, dependent: :destroy
  has_many :email_messages, -> { order(:created_at) }, dependent: :destroy

  before_validation :default_last_activity_at, on: :create
  after_save :update_agent_last_activity, if: :saved_change_to_last_activity_at?
  after_destroy :update_agent_last_activity

  def snippet
    email_messages.last&.text.to_s.tr("\n", " ").strip.truncate(140)
  end

  def last_sender
    email_messages.where(direction: :inbound).last&.from_email
  end

  private

  def default_last_activity_at
    self.last_activity_at ||= Time.current
  end

  def update_agent_last_activity
    agent.update_column(:last_activity_at, agent.email_threads.maximum(:last_activity_at))
  end
end
