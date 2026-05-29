class WebConnector < ApplicationRecord
  belongs_to :user

  has_many :agent_web_connectors, dependent: :destroy
  has_many :agents, through: :agent_web_connectors

  validates :name, presence: true
  validates :urls, presence: { message: "must include at least one URL" }

  before_validation { self.urls = Array(urls).map { |u| u.to_s.strip }.reject(&:blank?) }
end
