require 'net/http'
require 'uri'
require 'json'

class ParticipantsController < ApplicationController
  
  before_action :set_tournament, only: [:create, :reload, :randomize, :destroy, :update, :clear, :tournament_master]
  before_action :tournament_master, only: [:randomize, :destroy, :clear]
  
  def new
    @participant = Participant.new()
    @participants = Participant.where.not(tournament_id: params[:tournament_id])
    @users = return_users_from_participants(@participants)
  end
  
  def create
    #登録の処理を書き込む
    players = params[:players]
    #t_id = params[:tournament_id]
    #players = users.rstrip.split(/\r?\n/).map {|player| player.chomp}
    if players.instance_of?(Array)
      players.each do |player|
        pa = Participant.new(tournament_id: @tournament.id, user_id: player)
        chapa = Challonge::Participant.create(:name => "#{User.find(player).name}", :tournament => Challonge::Tournament.find(@tournament.id_number))
        pa.challonge_participant_id = chapa.id
        pa.save
      end
    else
      pa = Participant.new(tournament_id: @tournament.id, user_id: players)
      chapa = Challonge::Participant.create(:name => "#{User.find(players).name}", :tournament => Challonge::Tournament.find(@tournament.id_number))
      pa.challonge_participant_id = chapa.id
      pa.save
    end
    
    #@tournament = Tournament.find(t_id)
    redirect_to @tournament
  end
  
  def index
    @participants = Participant.where(tournament_id: params[:tournament_id])
  end
  
  def reload
    #@tournament = Tournament.find(params[:tournament_id])
    t = Challonge::Tournament.find(@tournament.id_number)
    t.reload
    flash[:success] = "トーナメント情報を更新しました。"
    redirect_to @tournament
  end
  
  def randomize
    #@tournament = Tournament.find(params[:tournament_id])
    t = Challonge::Tournament.find(@tournament.id_number)
=begin
    url = URI.parse("https://api.challonge.com/v1/tournaments/#{tournament.id_number}/participants/randomize")
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth Challonge::API.username, Challonge::API.key
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      t.reload
      flash[:success] = "参加者を並び替えました。"
    else
      flash[:danger] = "並び替えに失敗しました。"
    end
=end    
    # get成功例
=begin
    uri = URI("https://api.challonge.com/v1/tournaments/#{tournament.id_number}.json")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth('TenTan441', 'RqayqZTRMe7TRXobnrkCGvlgh4u11gYzRpAt7i5D')
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }
    if res.is_a?(Net::HTTPSuccess)
      access_token = JSON.parse(res.body)['access_token']
    else
      abort "get access_token failed: body=" + res.body
    end
    debugger
=end    

    # post成功例
=begin
    post_body_hash = {:tournament => t.id}
    post_body_json = JSON.pretty_generate(post_body_hash)
    uri = URI("https://api.challonge.com/v1/tournaments/#{tournament.id_number}/participants/randomize.json")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth('TenTan441', 'RqayqZTRMe7TRXobnrkCGvlgh4u11gYzRpAt7i5D')
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }
    if res.is_a?(Net::HTTPSuccess)
      puts JSON.pretty_generate(JSON.parse(res.body))
      flash[:success] = "並び替えました。"
    else
      #abort "call api failed: body=" + res.body
      flash[:danger] = "並び替えに失敗しました。"
    end
=end

    bool, access_token = post_challonge_api({:tournament => t.id}, "/#{@tournament.id_number}/participants/randomize")
  
    if bool
      flash[:success] = "並び替えました。"
      puts access_token
    else
      flash[:danger] = "並び替えに失敗しました。"
      puts access_token
    end
    t.reload
    redirect_to @tournament
  end
  
  def show

  end
  
  def update
    #登録の処理を書き込む
    players = params[:players] # user_idが記録されている
    #t_id = params[:tournament_id]
    
    # 登録されているキャラ
    registered_players = return_users_from_participants(Participant.where(tournament_id: @tournament.id))
    
    #players = users.rstrip.split(/\r?\n/).map {|player| player.chomp}
    players.each do |player|
      pa = Participant.new(tournament_id: @tournament.id, user_id: player)
      chapa = Challonge::Participant.create(:name => "#{User.find(player).name}", :tournament => Challonge::Tournament.find(@tournament.id_number))
      pa.challonge_participant_id = chapa.id
      pa.save
    end
    
    #@tournament = Tournament.find(t_id)
    redirect_to @tournament
  end
  
  def destroy
    participant = Participant.find(params[:id])
    #@tournament = Tournament.find(params[:tournament_id])

    bool, access_token = delete_challonge_api({}, "/#{@tournament.id_number}/participants/#{participant.challonge_participant_id}")
    
    if bool
      flash[:success] = "参加を取り消しました。"
      participant.destroy
      puts access_token
    else
      flash[:danger] = "参加の取り消しに失敗しました。"
      puts access_token
    end

    redirect_to @tournament
  end
  
  def clear
    #@tournament = Tournament.find(params[:tournament_id])
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
      if params[:id].present?
        @tournament = Tournament.find(params[:id])
      elsif params[:tournament_id].present?
        @tournament = Tournament.find(params[:tournament_id])
      end
      @t = Challonge::Tournament.find(@tournament.id_number)
    end
    
    def tournament_master
      unless User.find(@tournament.master) == current_user
        flash[:danger] = "権限がありません。"
        redirect_to current_user
      end
    end
end
