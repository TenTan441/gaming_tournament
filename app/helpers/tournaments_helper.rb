module TournamentsHelper
  
  def master_tournament(tournament)
    return User.find(tournament.master)
  end
  
  def master?(tournament)
    current_user == master_tournament(tournament)
  end
  
  # 大会管理者かマッチの当事者の場合はtrue, それ以外はfalseを返す
  def master_or_party?(tournament, player1, player2)
    (current_user == master_tournament(tournament) ) || 
    (current_user == return_user_from_participant(player1) ) || 
    (current_user == return_user_from_participant(player2) )
  end
  
  def master_or_participants?(tournament)
    unless current_user == master_tournament(tournament)
      users = return_users_from_participants(Participant.where(tournament_id: tournament.id))
      if users.include?(current_user) == false
        return false
      end
    end
    return true
  end
  
  def game_title_from_number(num)
    game_title = case num
    when "0" 
      "Super Smash Bros."
    when "1" 
      "Super Smash Bros. Melee"
    when "2" 
      "Super Smash Bros. Brawl"
    when "3"
      "Super Smash Bros. for 3DS"
    when "4"
      "Super Smash Bros. for Wii U"
    when "5"
      "Super Smash Bros. Ultimate"
    end
    return game_title
  end
  
  # datetimepickerで渡された文字列をdatetime型にして返す
  def datetimepicker_parse(picker)
    return DateTime.parse(picker + " +09:00")
  end
end
