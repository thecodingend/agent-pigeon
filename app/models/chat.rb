class Chat < ApplicationRecord
  acts_as_chat

  belongs_to :email_thread, optional: true
end
