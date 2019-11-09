module ParticipantsHelper
  
  def return_user_from_participant(participant)
    user = User.find(Participant.find_by(challonge_participant_id: participant).user_id)
    return user
  end
  
  def return_users_from_participants(participants)
    users = User.all

    # 参加者がいる状態では未参加者のみを抽出する
    unless participants.blank?
      already_participants = []
      participants.each do |participant|
        already_participants.push(User.find(participant.user_id))
      end
      
      return users - already_participants
    end
    
    return users
  end
end
