class Message < ApplicationRecord
  belongs_to :user
  
  validates :user_to, presence: true
  validates :text, presence: true
end
