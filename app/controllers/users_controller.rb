class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    respond_to do |format|
      format.html do
        @message = Message.new()
      end
      format.js do
        if params[:inbox].present?
          messages = params
          @message_inbox = Message.where(user_to: @user.id).from_search(messages[:user_id]).text_search(messages[:text]).edited_at_search(messages[:from], messages[:to]).order(edited_at: "DESC").paginate(page: params[:inbox_page], per_page: 10)
        elsif params[:inbox_page].present?
          @message_inbox = Message.where(user_to: @user.id).order(edited_at: "DESC").paginate(page: params[:indox_page], per_page: 10)
        elsif params[:outbox].present?
          messages = params
          @message_outbox = Message.where(user_id: @user.id).to_search(messages[:user_to]).text_search(messages[:text]).edited_at_search(messages[:from], messages[:to]).order(edited_at: "DESC").paginate(page: params[:outbox_page], per_page: 10)
        elsif params[:outbox_page].present?
          @message_outbox = Message.where(user_id: @user.id).order(edited_at: "DESC").paginate(page: params[:outbox_page], per_page: 10)
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
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def send_dm
    user = User.find(params[:user_id])
    text = params[:user][:text]
    result = TwitterApi.new(user.uid, text).call
    result ? flash[:success] = "DM送信に成功しました。" : flash[:danger] = "DM送信に失敗しました。繰り返される場合は管理者へ連絡してください。"
    redirect_to user
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

    # ログイン済みのユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end

    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
    
    def user_image_params
      params.require(:user).permit(:image)
    end
end