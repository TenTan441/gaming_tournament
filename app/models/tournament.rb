class Tournament < ApplicationRecord
  validates :name, presence: true
  has_many :participants, dependent: :destroy
end
