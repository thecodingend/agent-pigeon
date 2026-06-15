class EmailConnectionSchema < ActiveRecord::Migration[8.1]
  def up
    rename_table :domains, :sending_domains

    remove_index :sending_domains, :user_id if index_exists?(:sending_domains, :user_id)
    remove_index :sending_domains, :hostname if index_exists?(:sending_domains, :hostname)

    change_column_null :sending_domains, :resend_domain_id, false
    add_column :sending_domains, :return_path_label, :string, null: false, default: "agentpigeon"

    add_index :sending_domains, :user_id
    add_index :sending_domains, :hostname, unique: true
    add_index :sending_domains, :resend_domain_id, unique: true

    remove_foreign_key :agents, column: :domain_id
    remove_index :agents, name: "index_agents_on_domain_id_and_local_part" if index_exists?(:agents, [ :domain_id, :local_part ], name: "index_agents_on_domain_id_and_local_part")
    remove_index :agents, name: "index_agents_on_domain_id" if index_exists?(:agents, :domain_id, name: "index_agents_on_domain_id")
    remove_column :agents, :domain_id
    remove_column :agents, :local_part

    create_table :email_connections do |t|
      t.references :agent, null: false, foreign_key: true, index: { unique: true }
      t.references :sending_domain, null: false, foreign_key: true
      t.string :support_address, null: false
      t.string :forwarding_address, null: false
      t.integer :forwarding_status, null: false, default: 0
      t.datetime :forwarding_verified_at

      t.timestamps
    end

    add_index :email_connections, :support_address, unique: true
    add_index :email_connections, :forwarding_address, unique: true

    create_table :resend_webhook_events do |t|
      t.string :svix_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}
      t.integer :status, null: false, default: 0
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end

    add_index :resend_webhook_events, :svix_id, unique: true
    add_index :resend_webhook_events, :event_type
    add_index :resend_webhook_events, :status
  end

  def down
    drop_table :resend_webhook_events
    drop_table :email_connections

    add_column :agents, :local_part, :string, null: false, default: "support"
    add_reference :agents, :domain, null: false, foreign_key: { to_table: :sending_domains }
    add_index :agents, [ :domain_id, :local_part ], unique: true

    remove_index :sending_domains, :resend_domain_id
    remove_index :sending_domains, :hostname
    remove_index :sending_domains, :user_id
    remove_column :sending_domains, :return_path_label
    change_column_null :sending_domains, :resend_domain_id, true

    add_index :sending_domains, :hostname, unique: true, name: "index_domains_on_hostname"
    add_index :sending_domains, :user_id, unique: true, name: "index_domains_on_user_id"

    rename_table :sending_domains, :domains
  end
end
