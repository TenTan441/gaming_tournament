class SessionsController < ApplicationController
  
  before_action :logged_in_user, only: [:new, :create, :twitter_login]
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      ActiveRecord::Type::Boolean.new.cast(params[:session][:remember_me]) ? remember(user) : forget(user)
      flash[:success] = "ようこそ、#{user.name}さん。"
      redirect_back_or user
    else
      flash.now[:danger] = '認証に失敗しました。'
      render :new
    end
  end
  
  def twitter_login
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    log_in user
    redirect_to user
  end
  
  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
  
  private
    def logged_in_user
      if !current_user.nil?
        flash[:success] = "既にログイン済みです。"
        redirect_to current_user
      end
    end
end
