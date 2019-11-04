module TournamentsHelper
  
  def master_tournament(tournament)
    return User.find(tournament.master)
  end
end
