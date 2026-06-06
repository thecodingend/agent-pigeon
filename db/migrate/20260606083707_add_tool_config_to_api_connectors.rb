class AddToolConfigToApiConnectors < ActiveRecord::Migration[8.1]
  def change
    add_column :api_connectors, :query_schema, :jsonb, null: false, default: {}
    add_column :api_connectors, :response_schema, :jsonb, null: false, default: {}
    add_column :api_connectors, :timeout_seconds, :integer, null: false, default: 10
    add_column :api_connectors, :max_response_bytes, :integer, null: false, default: 1.megabyte
    add_column :api_connectors, :enabled, :boolean, null: false, default: true
    add_column :api_connectors, :auth_type, :string, null: false, default: "bearer"
  end
end
