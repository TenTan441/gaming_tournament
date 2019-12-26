class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :ever_logged_in_user, only: [:new, :create]
  before_action :admin_or_correct_user, only: [:edit, :update, :destroy]
  before_action :admin_only, only: :show

  def index
    @users = User.where(admin: false).search(params[:search]).paginate(page: params[:page], per_page: 10)
  end

  def show
    respond_to do |format|
      format.html do
        @message = Message.new()
        if current_user?(@user) || current_user.admin?
          @tournaments = Tournament.where(id: Participant.where(user_id: current_user.id)
                                                         .pluck(:tournament_id))
                                   .or(Tournament.where(user_id: current_user.id))
                                   .distinct
                                   .order(id: "DESC").paginate(page: params[:page], per_page: 10)
        else
          @tournaments = Tournament.where(id: Participant.where(user_id: @user.id)
                                                         .pluck(:tournament_id),
                                          private: false)
                                   .order(id: "DESC").paginate(page: params[:page], per_page: 10)
        end
      end
      format.js do
        if params[:inbox].present?
          messages = params
          @message_inbox = Message.where(user_to: @user.id)
                                  .from_search(messages[:user_id])
                                  .text_search(messages[:text])
                                  .edited_at_search(messages[:from], messages[:to])
                                  .order(edited_at: "DESC")
                                  .paginate(page: params[:inbox_page], per_page: 10)
        elsif params[:inbox_page].present?
          @message_inbox = Message.where(user_to: @user.id)
                                  .order(edited_at: "DESC")
                                  .paginate(page: params[:indox_page], per_page: 10)
        elsif params[:outbox].present?
          messages = params
          @message_outbox = Message.where(user_id: @user.id)
                                   .to_search(messages[:user_to])
                                   .text_search(messages[:text])
                                   .edited_at_search(messages[:from], messages[:to])
                                   .order(edited_at: "DESC")
                                   .paginate(page: params[:outbox_page], per_page: 10)
        elsif params[:outbox_page].present?
          @message_outbox = Message.where(user_id: @user.id)
                                   .order(edited_at: "DESC")
                                   .paginate(page: params[:outbox_page], per_page: 10)
        elsif params[:tournaments]
          if current_user?(@user) || current_user.admin?
            @tournaments = Tournament.where(id: Participant.where(user_id: current_user.id)
                                                           .pluck(:tournament_id))
                                     .or(Tournament.where(user_id: current_user.id))
                                     .distinct
                                     .name_search(params[:name])
                                     .master_search(params[:user_id])
                                     .title_search(params[:game_title])
                                     .status_search(params[:status])
                                     .start_time_search(params[:from], params[:to])
                                     .order(id: "DESC")
                                     .paginate(page: params[:page], per_page: 10)
          else
            @tournaments = Tournament.where(id: Participant.where(user_id: @user.id)
                                                           .pluck(:tournament_id),
                                            private: false)
                                     .name_search(params[:name])
                                     .master_search(params[:user_id])
                                     .title_search(params[:game_title])
                                     .status_search(params[:status])
                                     .start_time_search(params[:from], params[:to])
                                     .order(id: "DESC")
                                     .paginate(page: params[:page], per_page: 10)
          end
        end
      end # format.js
    end # respond_to do |format|
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
    else
      flash[:danger] = "更新に失敗しました。"
    end
    redirect_to @user
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to root_url
  end
  
  def title_character
    title = params[:game_title]
    @character = Character.find_by(game_title: title, user_id: params[:user_id])
  end
  
  def contact
    @user = User.find(params[:user_id])
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :image, :twitter_private, :description)
    end

    # beforeフィルター

    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end

    # 未ログインユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    # ログイン済みユーザか確認
    def ever_logged_in_user
      if logged_in?
        flash[:success] = "既にログイン済みです。"
        redirect_to current_user
      end
    end

    # アクセスしたユーザーがシステム管理権限所有かマイページの所有者かどうか判定します。
    def admin_or_correct_user
      redirect_to root_url unless (current_user.admin? || current_user?(@user))
    end
    
    def admin_only
      redirect_to root_url if (!current_user.admin? && @user.admin? )
    end
    
    def user_image_params
      params.require(:user).permit(:image)
    end
end