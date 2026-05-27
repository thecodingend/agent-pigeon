class CreateAgentWebConnectors < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_web_connectors do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :web_connector, null: false, foreign_key: true

      t.timestamps
    end

    add_index :agent_web_connectors, [ :agent_id, :web_connector_id ], unique: true
  end
end
