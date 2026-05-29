class CreateDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :domains do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :hostname, null: false
      t.string :resend_domain_id
      t.integer :status, null: false, default: 0
      t.jsonb :dns_records, null: false, default: []
      t.datetime :verified_at

      t.timestamps
    end

    add_index :domains, :hostname, unique: true
  end
end
