require "securerandom"

class EmailConnection < ApplicationRecord
  PERSONAL_DOMAINS = %w[
    gmail.com
    googlemail.com
    outlook.com
    hotmail.com
    live.com
    yahoo.com
    icloud.com
    me.com
    aol.com
    proton.me
    protonmail.com
  ].freeze

  belongs_to :agent
  belongs_to :sending_domain

  enum :forwarding_status, { needs_forwarding: 0, ready: 1 }, default: :needs_forwarding

  validates :support_address, presence: true, uniqueness: { case_sensitive: false }
  validates :forwarding_address, presence: true, uniqueness: { case_sensitive: false }
  validate :support_address_shape
  validate :support_address_domain_allowed
  validate :support_address_matches_sending_domain
  validate :support_address_domain_does_not_change, on: :update
  validate :agent_and_sending_domain_share_user

  before_validation do
    self.support_address = support_address.to_s.downcase.strip
    self.forwarding_address = forwarding_address.to_s.downcase.strip
  end
  before_validation :generate_forwarding_address, on: :create

  def self.domain_from(address)
    local_part, domain = address.to_s.downcase.strip.split("@", 2)
    return nil if local_part.blank? || domain.blank? || domain.include?("@")

    domain
  end

  def complete?
    sending_domain.verified? && ready?
  end

  private

  def generate_forwarding_address
    return if forwarding_address.present?

    receiving_domain = Rails.application.config.x.resend.receiving_domain
    raise "Missing RESEND_RECEIVING_DOMAIN" if receiving_domain.blank?

    self.forwarding_address = "ec_#{SecureRandom.alphanumeric(12).downcase}@#{receiving_domain}"
  end

  def support_address_shape
    return if support_address.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)

    errors.add(:support_address, "is invalid")
  end

  def support_address_domain_allowed
    domain = self.class.domain_from(support_address)
    return if domain.blank?
    return unless PERSONAL_DOMAINS.include?(domain)

    errors.add(:support_address, "Use an email address on a domain you control, such as support@yourcompany.com.")
  end

  def support_address_matches_sending_domain
    domain = self.class.domain_from(support_address)
    return if domain.blank? || sending_domain.blank?
    return if domain == sending_domain.hostname

    errors.add(:support_address, "must be on #{sending_domain.hostname}")
  end

  def support_address_domain_does_not_change
    return unless will_save_change_to_support_address?

    old_domain = self.class.domain_from(support_address_was)
    new_domain = self.class.domain_from(support_address)
    return if old_domain.blank? || new_domain.blank? || old_domain == new_domain

    errors.add(:support_address, "domain cannot be changed")
  end

  def agent_and_sending_domain_share_user
    return if agent.blank? || sending_domain.blank?
    return if agent.user_id == sending_domain.user_id

    errors.add(:sending_domain, "must belong to the agent owner")
  end
end
