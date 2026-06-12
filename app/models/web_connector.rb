class WebConnector < ApplicationRecord
  DEFAULT_MAX_DEPTH = 1
  DEFAULT_MAX_PAGES = 20
  DEFAULT_DELAY_SECONDS = 1
  DEFAULT_CONCURRENCY = 2
  MAX_DEPTH = 3
  MAX_PAGES = 100
  MAX_DELAY_SECONDS = 10
  MAX_CONCURRENCY = 5

  belongs_to :user

  has_many :agent_web_connectors, dependent: :destroy
  has_many :agents, through: :agent_web_connectors

  after_initialize :apply_crawl_defaults, if: :new_record?

  validates :name, presence: true
  validates :urls, presence: { message: "must include at least one URL" }
  validates :max_depth, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_DEPTH }
  validates :max_pages, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_PAGES }
  validates :delay_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_DELAY_SECONDS }
  validates :concurrency, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_CONCURRENCY }
  validates :allow_pdfs, inclusion: { in: [ true, false ] }

  before_validation :normalize_urls

  validate :urls_allowed

  private

  def apply_crawl_defaults
    self.max_depth ||= DEFAULT_MAX_DEPTH
    self.max_pages ||= DEFAULT_MAX_PAGES
    self.delay_seconds ||= DEFAULT_DELAY_SECONDS
    self.concurrency ||= DEFAULT_CONCURRENCY
    self.allow_pdfs = false if allow_pdfs.nil?
  end

  def normalize_urls
    self.urls = Array(urls).map do |url|
      raw = url.to_s.strip
      UrlPolicy.normalize(raw) || raw
    end.reject(&:blank?).uniq
  end

  def urls_allowed
    urls.each do |url|
      errors.add(:urls, "#{url} is not allowed") unless UrlPolicy.allowed?(url)
    end
  end
end
