class AddEmailThreadToChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :chats, :email_thread, null: true, foreign_key: true
  end
end
