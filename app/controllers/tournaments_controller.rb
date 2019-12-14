class TournamentsController < ApplicationController
  
  before_action :set_tournament, only: [:show, :edit, :update, :destroy, :toggle, :start, :reset, :finalize, :tournament_master, :master_or_party, :privated_tournament]
  before_action :privated_tournament, only: [:edit, :show, :toggle, :start, :reset, :finalize, :update, :destroy]
  before_action :tournament_master, only: [:start, :edit, :reset, :finalize, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html do
        if !current_user.nil? 
          @tournaments = Tournament.where(private: false).or(Tournament.where(id: Participant.where(user_id: current_user.id)
                                                                                             .pluck(:tournament_id),
                                                                              private: true))
                                                         .or(Tournament.where(master: current_user.id))
                                                         .distinct #　重複を消す
                                                         .order(id: "DESC")
                                                         .paginate(page: params[:page], per_page: 10)
        else
          @tournaments = Tournament.where(private: false).order(id: "DESC").paginate(page: params[:page], per_page: 10)
        end
      end
      format.js do
        if params[:tournaments].present?
          if !current_user.nil?
            @tournaments = Tournament.where(private: false).or(Tournament.where(id: Participant.where(user_id: current_user.id)
                                                                                               .pluck(:tournament_id),
                                                                                private: true))
                                                           .or(Tournament.where(master: current_user.id))
                                                           .distinct #　重複を消す
                                                           .name_search(params[:name])
                                                           .master_search(params[:master])
                                                           .title_search(params[:game_title])
                                                           .status_search(params[:status])
                                                           .start_time_search(params[:from], params[:to])
                                                           .order(id: "DESC")
                                                           .paginate(page: params[:page], per_page: 10)
          else
            @tournaments = Tournament.where(private: false).name_search(params[:name])
                                                           .master_search(params[:master])
                                                           .title_search(params[:game_title])
                                                           .status_search(params[:status])
                                                           .start_time_search(params[:from], params[:to])
                                                           .order(id: "DESC")
                                                           .paginate(page: params[:page], per_page: 10)
          end
        end
      end
                                                    
    end
  end
  
  def new
    @tournament = Tournament.new
  end
  
  def create
    @tournament = Tournament.new(tournament_params)
    t = params[:tournament]
    case tournament_type = t[:elimination_type]
    when 'single elimination'
      bool, access_token = post_challonge_api({:tournament => {:name => t[:name], 
                                                              :url => t[:url],
                                                              :tournament_type => t[:elimination_type],
                                                              :start_at => t[:start_time],
                                                              :private => ActiveRecord::Type::Boolean.new.cast(t[:private]),
                                                              :description => t[:description],
                                                              :hold_third_place_match => ActiveRecord::Type::Boolean.new.cast(t[:hold_third_place_match])}
                                              }, "")
    when 'double elimination'
      bool, access_token = post_challonge_api({:tournament => {:name => t[:name], 
                                                              :url => t[:url],
                                                              :tournament_type => t[:elimination_type],
                                                              :start_at => t[:start_time],
                                                              :private => true,
                                                              :description => t[:description],
                                                              :grand_finals_modifier => t[:grand_finals_modifier]}
                                              }, "")
    when 'round robin'
      if t[:ranked_by] == "custom"
        bool, access_token = post_challonge_api({:tournament => {:name => t[:name], 
                                                                :url => t[:url],
                                                                :tournament_type => t[:elimination_type],
                                                                :start_at => t[:start_time],
                                                                :private => true,
                                                                :description => t[:description],
                                                                :ranked_by => t[:ranked_by],
                                                                :rr_pts_for_match_win => t[:rr_pts_for_match_win],
                                                                :rr_pts_for_match_tie => t[:rr_pts_for_match_tie],
                                                                :rr_pts_for_game_win => t[:rr_pts_for_game_win],
                                                                :rr_pts_for_game_tie => t[:rr_pts_for_game_tie]}
                                                }, "")
      else
        bool, access_token = post_challonge_api({:tournament => {:name => t[:name], 
                                                                :url => t[:url],
                                                                :tournament_type => t[:elimination_type],
                                                                :start_at => t[:start_time],
                                                                :private => true,
                                                                :description => t[:description]}
                                                }, "")
      end
    end

    if bool # && s.save
      @tournament.id_number = access_token["tournament"]["id"]
      @tournament.status = "準備中"
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
    @challonge = get_challonge_api({}, "/#{@tournament.id_number}")
  end
  
  def show
    @participants = Participant.where(tournament_id: @tournament)
    @challonge = get_challonge_api({}, "/#{@tournament.id_number}")
    
    # 開催中と終了したマッチングを取得
    @matches_opening = get_challonge_api({:state => "open"}, "/#{@tournament.id_number}/matches")

    if @challonge["tournament"]["state"] == "pending"
      @started = false
    else
      @started = true
    end

    @message = Message.new()
    @participant = Participant.new()
    @not_yet_users = return_users_from_non_participants(@participants)
    
    @participants_search = @participants.where(user_id: User.search(params[:search]).order(:id).pluck(:id))
                                        .paginate(page: params[:page], per_page: 10)
  end
  
  def toggle
    @state = params[:state]
    case @state
    when 'open'
      @matches_opening = get_challonge_api({:state => "open"}, "/#{@tournament.id_number}/matches")
    when 'complete'
      @matches_complete = get_challonge_api({:state => "complete"}, "/#{@tournament.id_number}/matches")
    end
    @challonge = get_challonge_api({}, "/#{@tournament.id_number}")
  end
  
  def start
    bool, access_token = post_challonge_api({}, "/#{@tournament.id_number}/start")
    
    if bool
      @tournament.status = "進行中"
      @tournament.save
      flash[:success] = "大会開始！"
    else
      flash[:danger] = "開始に失敗しました。"
    end
    
    redirect_to @tournament
  end
  
  def reset
    bool, access_token = post_challonge_api({}, "/#{@tournament.id_number}/reset")
    
    if bool
      if @tournament.status == "完了"
        Participant.where(tournament_id: @tournament.id).update_all(ranking: nil)
      end
      @tournament.status = "準備中"
      @tournament.save
      flash[:info] = "大会がやり直されました。"
    else
      flash[:danger] = "やり直しに失敗しました。"
    end
    
    redirect_to @tournament
  end
  
  def finalize
    bool, access_token = post_challonge_api({}, "/#{@tournament.id_number}/finalize")
    
    if bool
      flash[:info] = "大会お疲れさまでした。"
      @tournament.status = "完了"
      @tournament.save
      
      @challonge_participants = get_challonge_api({}, "/#{@tournament.id_number}/participants")
      @challonge_participants.each do |challonge_participant|
        participant = Participant.find_by(challonge_participant_id: challonge_participant["participant"]["id"])
        participant.ranking = challonge_participant["participant"]["final_rank"]
        participant.save
      end
    else
      flash[:danger] = "送信に失敗しました。管理者へ連絡してください。"
    end
    
    redirect_to @tournament
  end
  
  def update
    t = params[:tournament]
    case tournament_type = t[:elimination_type]
    when 'single elimination'
      bool, access_token = put_challonge_api({:tournament => {:name => t[:name], 
                                                              :url => t[:url],
                                                              :tournament_type => t[:elimination_type],
                                                              :start_at => t[:start_time],
                                                              :private => true,
                                                              :description => t[:description],
                                                              :hold_third_place_match => t[:hold_third_place_match],
                                                              :grand_finals_modifier => t[:grand_finals_modifier],
                                                              :ranked_by => t[:ranked_by],
                                                              :rr_pts_for_match_win => t[:rr_pts_for_match_win],
                                                              :rr_pts_for_match_tie => t[:rr_pts_for_match_tie],
                                                              :rr_pts_for_game_win => t[:rr_pts_for_game_win],
                                                              :rr_pts_for_game_tie => t[:rr_pts_for_game_tie]}
                                              }, "/#{@tournament.id_number}")
    when 'double elimination'
      bool, access_token = put_challonge_api({:tournament => {:name => t[:name], 
                                                              :url => t[:url],
                                                              :tournament_type => t[:elimination_type],
                                                              :start_at => t[:start_time],
                                                              :private => true,
                                                              :description => t[:description],
                                                              :grand_finals_modifier => t[:grand_finals_modifier]}
                                              }, "/#{@tournament.id_number}")
    when 'round robin'
      if t[:ranked_by] == "custom"
        bool, access_token = put_challonge_api({:tournament => {:name => t[:name], 
                                                                :url => t[:url],
                                                                :tournament_type => t[:elimination_type],
                                                                :start_at => t[:start_time],
                                                                :private => true,
                                                                :description => t[:description],
                                                                :ranked_by => t[:ranked_by],
                                                                :rr_pts_for_match_win => t[:rr_pts_for_match_win],
                                                                :rr_pts_for_match_tie => t[:rr_pts_for_match_tie],
                                                                :rr_pts_for_game_win => t[:rr_pts_for_game_win],
                                                                :rr_pts_for_game_tie => t[:rr_pts_for_game_tie]}
                                                }, "/#{@tournament.id_number}")
      else
        bool, access_token = put_challonge_api({:tournament => {:name => t[:name], 
                                                                :url => t[:url],
                                                                :tournament_type => t[:elimination_type],
                                                                :start_at => t[:start_time],
                                                                :private => true,
                                                                :description => t[:description]}
                                                }, "/#{@tournament.id_number}")
      end
    end
    
    if bool # && s.save
      if @tournament.update_attributes(tournament_params)
        flash[:success] = '更新に成功しました。'
        redirect_to @tournament
      else
        flash[:danger] = "更新に失敗しました！"
        render :edit
      end
    else
      flash[:danger] = "更新に失敗しました。"
      puts access_token
      @challonge = get_challonge_api({}, "/#{@tournament.id_number}")
      render :edit
    end
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
      params.require(:tournament).permit(:master, :name, :private, :game_title, :description, :start_time)
    end
    
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
        redirect_to logged_in? ? current_user : root_path
      end
    end
    
    def privated_tournament
      if @tournament.private == true && master_or_participants?(@tournament) == false
        flash[:danger] = "非公開の大会です"
        redirect_to root_path
      end
    end
end