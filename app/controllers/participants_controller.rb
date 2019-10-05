class ParticipantsController < ApplicationController
  def new
    @participant = Participant.new()
  end
  
  def create
    #登録の処理を書き込む
    players = params[:players]
    t_id = params[:tournament_id]
    #players = users.rstrip.split(/\r?\n/).map {|player| player.chomp}
    players.each do |player|
      pa = Participant.new(tournament_id: t_id, user_id: player)
      pa.save
      Challonge::Participant.create(:name => "#{User.find(player).name}", :tournament => Challonge::Tournament.find(Tournament.find(t_id).id_number))
    end
    redirect_to tournament_participants_url
  end
  
  def index
    @participants = Participant.where(tournament_id: params[:tournament_id])
  end
end
