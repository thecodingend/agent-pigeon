class CreateApiConnectors < ActiveRecord::Migration[8.1]
  def change
    create_table :api_connectors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.string :base_url, null: false
      t.integer :http_method, null: false, default: 0
      t.jsonb :request_example, null: false, default: {}
      t.jsonb :response_example, null: false, default: {}
      t.text :auth_token

      t.timestamps
    end
  end
end
