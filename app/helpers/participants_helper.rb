module ParticipantsHelper
  
  def return_user_from_participant(participant)
    return User.find(Participant.find_by(challonge_participant_id: participant).user_id)
  end
  
  def participant_to_user(participant)
    return User.find(Participant.find(participant.id).user_id)
  end
  
  # 参加者の一覧をユーザ情報へ変換する
  def return_users_from_participants(participants)
    users = []

    participants.each do |participant|
      users.push(User.find(participant.user_id))
    end
    
    return users
  end
  
  def return_user_id_from_participant(participants)
    users = []
    
    participants.each do |participant|
      users.push(participant.user_id)
    end
    
    return users
  end
  
  # 大会の未参加者を抽出する
  def return_users_from_non_participants(participants)
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
