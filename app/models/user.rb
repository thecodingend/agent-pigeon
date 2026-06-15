class User < ApplicationRecord
  enum :role, { regular: 0, admin: 1 }, default: :regular

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable, :omniauthable,
    omniauth_providers: [ :google_oauth2 ]

  has_many :sending_domains, dependent: :restrict_with_error
  has_many :agents, dependent: :destroy
  has_many :api_connectors, dependent: :destroy
  has_many :web_connectors, dependent: :destroy

  def email_connection
    agents.includes(email_connection: :sending_domain).find(&:email_connection)&.email_connection
  end

  def email_connection_complete?
    email_connection&.complete? || false
  end

  def self.from_google(auth)
    user = find_by(provider: auth.provider, uid: auth.uid) ||
      find_or_initialize_by(email: auth.info.email.downcase)

    user.provider = auth.provider
    user.uid = auth.uid
    user.password = Devise.friendly_token[0, 32] if user.encrypted_password.blank?
    user.skip_confirmation!
    user.save!
    user
  end
end
