class Participant < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :tournament, optional: true
end
