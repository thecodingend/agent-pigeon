class CreateEmailMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :email_messages do |t|
      t.references :email_thread, null: false, foreign_key: true
      t.references :message, null: true, foreign_key: true
      t.integer :direction, null: false
      t.string :from_email, null: false
      t.jsonb :to_emails, null: false, default: []
      t.jsonb :cc_emails, null: false, default: []
      t.string :subject, null: false, default: ""
      t.text :text
      t.text :html
      t.string :mime_message_id
      t.string :in_reply_to
      t.text :references_header, array: true, null: false, default: []
      t.integer :provider, null: false, default: 0
      t.string :provider_message_id
      t.jsonb :provider_payload, null: false, default: {}
      t.datetime :delivered_at
      t.datetime :received_at

      t.timestamps
    end

    add_index :email_messages, [ :provider, :provider_message_id ], unique: true, where: "provider_message_id IS NOT NULL"
    add_index :email_messages, [ :email_thread_id, :created_at ]
  end
end
