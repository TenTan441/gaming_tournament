require 'net/http'
require 'uri'
require 'json'


class TournamentsController < ApplicationController
  
  before_action :set_tournament, only: [:show, :edit, :update, :destroy, :reload, :start, :reset, :finalize]
  
  def index
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
    if @tournament.save && t.save # && s.save
      @tournament.id_number = t.id
      @tournament.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @tournament
    else
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
    if tournament["tournament"]["state"] == "pending"
      @started = false
    else
      @started = true
    end
    #ms.select {|hash| hash.state == "open"}
    @t.reload
  end
  
  def start
    @t.start!
    flash[:success] = "大会開始！"
    redirect_to @tournament
  end
  
  def reset
    @t.reset!
    flash[:info] = "大会がやり直されました。"
    redirect_to @tournament
  end
  
  def finalize
    bool, access_token = post_challonge_api({}, "/#{@t.id}/finalize")
    if bool
      flash[:info] = "大会お疲れさまでした。"
    else
      flash[:danger] = "送信に失敗しました。管理者へ連絡してください。"
    end
    redirect_to @tournament
  end
  
  def update
  end
  
  def destroy
    @tournament.destroy
    flash[:success] = "#{@tournament.name}のデータを削除しました。"
    redirect_to current_user
  end
  
  private
  
    def tournament_params
      params.require(:tournament).permit(:name, :private, :game_title, :url, :description, :group_stage_enabled, :elimination_type, :hold_third_place_match, :start_time)
    end
    
    def set_tournament
      if params[:id].present?
        @tournament = Tournament.find(params[:id])
      elsif params[:tournament_id].present?
        @tournament = Tournament.find(params[:tournament_id])
      end
      @t = Challonge::Tournament.find(@tournament.id_number)
    end
end