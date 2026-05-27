class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.string :name, null: false
      t.string :local_part, null: false
      t.text :system_prompt, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.integer :inbox_policy, null: false, default: 0

      t.timestamps
    end

    add_index :agents, [ :domain_id, :local_part ], unique: true
  end
end
