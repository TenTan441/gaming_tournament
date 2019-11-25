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
end
