class CreateWebConnectors < ActiveRecord::Migration[8.1]
  def change
    create_table :web_connectors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.text :urls, array: true, null: false, default: []

      t.timestamps
    end
  end
end
