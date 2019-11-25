class ParticipantsController < ApplicationController
  
  before_action :set_tournament, only: [:new, :create, :reload, :randomize, :destroy, :update, :clear, :tournament_master]
  before_action :tournament_master, only: [:randomize, :destroy, :clear]
  
  def new
    @participant = Participant.new()
    @participants = Participant.where(tournament_id: @tournament)
    @not_yet_users = return_users_from_non_participants(@participants)
  end
  
  def create
    #登録の処理を書き込む
    players = params[:players]

    if players.instance_of?(Array)
      players.each do |player|
        if !player.nil?
          pa = Participant.new(tournament_id: @tournament.id, user_id: player)
          bool, access_token = post_challonge_api({:participant => {:name => User.find(player).name}}, "/#{@tournament.id_number}/participants")
          
          if bool
            pa.challonge_participant_id = access_token["participant"]["id"]
            pa.save
          end
        end
      end
    else
      pa = Participant.new(tournament_id: @tournament.id, user_id: players)
      bool, access_token = post_challonge_api({:participant => {:name => User.find(players).name}}, "/#{@tournament.id_number}/participants")
        
      if bool
        pa.challonge_participant_id = access_token["participant"]["id"]
        pa.save
      end
    end
    
    redirect_to @tournament
  end
  
  def index
    @participants = Participant.where(tournament_id: params[:tournament_id])
  end
  
  def reload
    flash[:success] = "トーナメント情報を更新しました。"
    redirect_to @tournament
  end
  
  def randomize
    bool, access_token = post_challonge_api({:tournament => @tournament.id_number}, "/#{@tournament.id_number}/participants/randomize")
  
    if bool
      flash[:success] = "並び替えました。"
      puts access_token
    else
      flash[:danger] = "並び替えに失敗しました。"
      puts access_token
    end
    redirect_to @tournament
  end
  
  def show

  end
  
  def update
    #登録の処理を書き込む
    players = params[:players] # user_idが記録されている

    players.each do |player|
      pa = Participant.new(tournament_id: @tournament.id, user_id: player)
      bool, access_token = post_challonge_api({:tournament => {:name => User.find(player).name}}, "/#{@tournament.id_number}/participants")
        
      if bool
        pa.challonge_participant_id = access_token["participant"]["id"]
        pa.save
      end
    end
    
    redirect_to @tournament
  end
  
  def destroy
    participant = Participant.find(params[:id])

    bool, access_token = delete_challonge_api({}, "/#{@tournament.id_number}/participants/#{participant.challonge_participant_id}")
    
    if bool
      flash[:success] = "#{participant_to_user(participant).name}さんの参加を取り消しました。"
      participant.destroy
      puts access_token
    else
      flash[:danger] = "参加の取り消しに失敗しました。"
      puts access_token
    end

    redirect_to @tournament
  end
  
  def clear
    bool, access_token = delete_challonge_api({}, "/#{@tournament.id_number}/participants/clear")
    
    if bool
      flash[:success] = "参加者を全て取り消しました。"
      Participant.where(tournament_id: @tournament.id).destroy_all
      puts access_token
    else
      flash[:danger] = "取り消しに失敗しました。"
      puts access_token
    end

    redirect_to @tournament
  end
  
  private
  
    def set_tournament
      if params[:tournament_id].present?
        @tournament = Tournament.find(params[:tournament_id])
      elsif params[:id].present?
        @tournament = Tournament.find(params[:id])
      end
    end
    
    def tournament_master
      unless User.find(@tournament.master) == current_user
        flash[:danger] = "権限がありません。"
        redirect_to current_user
      end
    end
end
