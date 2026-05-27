class AgentWebConnector < ApplicationRecord
  belongs_to :agent
  belongs_to :web_connector, counter_cache: :agents_count

  validates :web_connector_id, uniqueness: { scope: :agent_id }
end
