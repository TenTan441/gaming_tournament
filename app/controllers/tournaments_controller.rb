require 'net/http'
require 'uri'
require 'json'


class TournamentsController < ApplicationController
  
  before_action :set_tournament, only: [:show, :edit, :update, :destroy, :reload, :start, :reset, :finalize, :tournament_master]
  before_action :tournament_master, only: [:start, :edit, :reset, :finalize, :destroy]
  
  def index
    @tournaments = Tournament.paginate(page: params[:page])
  end
  
  def new
    @tournament = Tournament.new
  end
  
  def create
    @tournament = Tournament.new(tournament_params)
    par = params[:tournament]
    t = Challonge::Tournament.new()
    t.name = par[:name]
    t.game_name = par[:game_title]
    t.url = par[:url]
    t.tournament_type = par[:elimination_type]
    t.start_at = par[:start_time]
    t.private = par[:private]
    t.description = par[:description]
    t.hold_third_place_match = par[:hold_third_place_match]
=begin
    ## 接続先URLを指定してパース
    uri = URI.parse("https://#{username}:#{password}@api.challonge.com/v1/tournaments")
    
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.path)
    req.basic_auth(username, password)
    
    req.set_form_data({tournament: {name: par[:name], tournament_type: par[:elimination_type], start_at: par[:start_time]}})

    res = http.request(req)
    debugger
=end
    if t.save # && s.save
      @tournament.id_number = t.id
      @tournament.status = '準備中'
      if @tournament.save
        flash[:success] = '新規作成に成功しました。'
        redirect_to @tournament
      else
        flash[:danger] = "新規作成に失敗しました。"
        render :new
      end
    else
      flash[:danger] = "Challengeにトーナメントを作れませんでした。"
      render :new
    end
  end
  
  def edit
  end
  
  def show
    @participants = Participant.where(tournament_id: @tournament)
    tournament = get_challonge_api({}, "/#{@t.id}")
    # 開催中のマッチングを取得
    @matches_opening = get_challonge_api({:state => "open"}, "/#{@t.id}/matches")
    @matches_complete = get_challonge_api({:state => "complete"}, "/#{@t.id}/matches")
    if tournament["tournament"]["state"] == "pending"
      @started = false
    else
      @started = true
    end
    #ms.select {|hash| hash.state == "open"}
    @t.reload
    
    @participant = Participant.new()
    @not_yet_users = return_users_from_non_participants(@participants)
  end
  
  def start
    @t.start!
    @tournament.status = '進行中'
    @tournament.save
    flash[:success] = "大会開始！"
    redirect_to @tournament
  end
  
  def reset
    @t.reset!
    @tournament.status = '準備中'
    @tournament.save
    flash[:info] = "大会がやり直されました。"
    redirect_to @tournament
  end
  
  def finalize
    bool, access_token = post_challonge_api({}, "/#{@t.id}/finalize")
    if bool
      flash[:info] = "大会お疲れさまでした。"
      @tournament.status = '終了'
      @tournament.save
    else
      flash[:danger] = "送信に失敗しました。管理者へ連絡してください。"
    end
    redirect_to @tournament
  end
  
  def update
  end
  
  def destroy

    bool, access_token = delete_challonge_api({}, "/#{@tournament.id_number}")
    
    if bool
      flash[:success] = "#{@tournament.name}の大会を削除しました。"
      puts access_token
      @tournament.destroy
      redirect_to current_user
    else
      flash[:danger] = "取り消しに失敗しました。"
      puts access_token
      redirect_to @tournament
    end
  end
  
  private
  
    def tournament_params
      params.require(:tournament).permit(:master, :name, :private, :game_title, :url, :description, :group_stage_enabled, :elimination_type, :hold_third_place_match, :start_time)
    end
    
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