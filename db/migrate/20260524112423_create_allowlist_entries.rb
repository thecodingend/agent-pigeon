class CreateAllowlistEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :allowlist_entries do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :pattern, null: false

      t.timestamps
    end

    add_index :allowlist_entries, [ :agent_id, :pattern ], unique: true
  end
end
