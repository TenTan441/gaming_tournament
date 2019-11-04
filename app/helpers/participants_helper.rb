module ParticipantsHelper
  
  def return_user_from_participant(participant)
    user = User.find(Participant.find_by(challonge_participant_id: participant).user_id)
    return user
  end
  
  def return_users_from_participants(participants)
    users = []
    unless participants.blank?
      participants.each do |participant|
        user = User.find(participant.user_id)
        users.push(user)
      end
    end
    return users
  end
end
