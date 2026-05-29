class AddSummaryColumnsToAgentsAndConnectors < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :email_threads_count, :integer, null: false, default: 0
    add_column :agents, :last_activity_at, :datetime
    add_column :api_connectors, :agents_count, :integer, null: false, default: 0
    add_column :web_connectors, :agents_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE agents
          SET email_threads_count = counts.thread_count,
              last_activity_at = counts.last_activity_at
          FROM (
            SELECT agent_id, COUNT(*) AS thread_count, MAX(last_activity_at) AS last_activity_at
            FROM email_threads
            GROUP BY agent_id
          ) counts
          WHERE agents.id = counts.agent_id
        SQL

        execute <<~SQL.squish
          UPDATE api_connectors
          SET agents_count = counts.agent_count
          FROM (
            SELECT api_connector_id, COUNT(*) AS agent_count
            FROM agent_api_connectors
            GROUP BY api_connector_id
          ) counts
          WHERE api_connectors.id = counts.api_connector_id
        SQL

        execute <<~SQL.squish
          UPDATE web_connectors
          SET agents_count = counts.agent_count
          FROM (
            SELECT web_connector_id, COUNT(*) AS agent_count
            FROM agent_web_connectors
            GROUP BY web_connector_id
          ) counts
          WHERE web_connectors.id = counts.web_connector_id
        SQL
      end
    end
  end
end
