require 'json'

class MatchesController < ApplicationController
  
  before_action :master_or_party, only: [:report]
  
  def report
    @match_id = params[:match][:suggested_play_order].to_i - 1
    @tournament_id = params[:match][:tournament_id]
    @player1 = params[:match][:player1_id]
    @player2 = params[:match][:player2_id]
  end
  
  def update
    t_id = params[:tournamentid]
    m = Challonge::Tournament.find(t_id).matches[params[:match_id].to_i]
    m.scores_csv = "#{params[:player1_score]}-#{params[:player2_score]}"
    m.winner_id = params[:player1_score] > params[:player2_score] ? params[:player1] : params[:player2]
    if m.save
      flash[:success] = "スコア送信しました。"
    else
      flash[:danger] = "スコア送信に失敗しました。繰り返される場合は管理者へ問い合わせてください。"
    end
    
    @tournament = Tournament.find(params[:tournament_id])
    redirect_to @tournament
  end
  
  def reset
    t_id = params[:match][:tournament_id]
    m_id = params[:match][:id]
    bool, access_token = post_challonge_api({}, "/#{t_id}/matches/#{m_id}/reopen")
    if bool
      flash[:success] = "マッチがやり直されました。"
    else
      flash[:danger] = "マッチのやり直しに失敗しました。繰り返される場合は管理者へ問い合わせてください。"
    end
    
    @tournament = Tournament.find(params[:tournament_id])
    redirect_to @tournament
  end
  
  private
  
    # 大会の管理者か当事者でないと更新作業ができないようにする
    def master_or_party
      # 現在のユーザ 管理者or当事者であればよい
      @tournament = Tournament.find(params[:tournament_id])
      unless master_or_party?(@tournament, params[:match][:player1_id], params[:match][:player2_id])
        redirect_to @tournament
      end
    end
end
