class AddChallongeParticipantIdToParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :participants, :challonge_participant_id, :integer
  end
end
