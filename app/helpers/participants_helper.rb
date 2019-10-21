module ParticipantsHelper
  
  def return_user_from_participant(participant)
    user = User.find(Participant.find_by(challonge_participant_id: participant).user_id)
    return user
  end
  
  def return_participant
  end
end
