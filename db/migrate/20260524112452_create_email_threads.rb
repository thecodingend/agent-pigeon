class CreateEmailThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :email_threads do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :subject, null: false, default: ""
      t.string :root_message_id
      t.text :participants, array: true, null: false, default: []
      t.datetime :last_activity_at, null: false

      t.timestamps
    end

    add_index :email_threads, [ :agent_id, :last_activity_at ], order: { last_activity_at: :desc }
  end
end
