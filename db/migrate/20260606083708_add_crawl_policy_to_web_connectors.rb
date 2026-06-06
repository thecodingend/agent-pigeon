class AddCrawlPolicyToWebConnectors < ActiveRecord::Migration[8.1]
  def change
    add_column :web_connectors, :max_depth, :integer, null: false, default: 1
    add_column :web_connectors, :max_pages, :integer, null: false, default: 20
    add_column :web_connectors, :delay_seconds, :integer, null: false, default: 1
    add_column :web_connectors, :concurrency, :integer, null: false, default: 2
    add_column :web_connectors, :allow_pdfs, :boolean, null: false, default: false
  end
end
