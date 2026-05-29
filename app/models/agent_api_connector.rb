class AgentApiConnector < ApplicationRecord
  belongs_to :agent
  belongs_to :api_connector, counter_cache: :agents_count

  validates :api_connector_id, uniqueness: { scope: :agent_id }
end
