module TournamentsHelper
  
  def master_tournament(tournament)
    return User.find(tournament.master)
  end
  
  def master?(tournament)
    current_user == master_tournament(tournament)
  end
  
  # 大会管理者かマッチの当事者の場合はtrue, それ以外はfalseを返す
  def master_or_party?(tournament, player1, player2)
    (current_user == master_tournament(tournament)) || 
    (current_user == return_user_from_participant(player1)) || 
    (current_user == return_user_from_participant(player2))
  end
end
