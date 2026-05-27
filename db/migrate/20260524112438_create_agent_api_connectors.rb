class CreateAgentApiConnectors < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_api_connectors do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :api_connector, null: false, foreign_key: true

      t.timestamps
    end

    add_index :agent_api_connectors, [ :agent_id, :api_connector_id ], unique: true
  end
end
