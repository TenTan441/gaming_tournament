class MessagesController < ApplicationController
  
  before_action :set_message, only: [:edit, :update, :destroy]
  before_action :only_admin_send_or_destinate, except: [:create, :creates, :destroys]

  #　メッセージ送信
  def create
    message = Message.new(message_params)
    message.user_to = params[:user_to]
    message.edited_at = DateTime.now
    
    if message.save
      flash[:success] = "メッセージを送信しました。"
    else
      flash[:danger] = "#{message.errors.full_messages.join(', ')}。"
    end
    
    # メッセージ作成したページへリダイレクト
    redirect_to params[:path]
  end
  
  #　メッセージ一括送信
  def creates

    users = params[:user_to]
    sent = 0
    users.each do |user|
      message = Message.new(message_params)
      message.user_to = user
      message.edited_at = DateTime.now
      if message.save
        sent += 1
      end
    end
    
    if sent > 0
      flash[:success] = "#{sent}件メッセージを送信しました"
    end
    
    @tournament = Tournament.find(params[:tournament_id])
    redirect_to @tournament
  end
  
  #　編集
  def edit
    @user = send_user(@message)
  end
  
  #　更新
  def update
    if @message.update_attributes(message_params)
      flash[:success] = "メッセージを更新しました。"
    else
      flash[:danger] = "#{@message.errors.full_messages.join(', ')}。"
    end
    redirect_to current_user
  end
  
  #　削除
  def destroy
    @message.destroy
    flash[:success] = "メッセージを削除しました。"
    redirect_to current_user
  end
  
  #　一括削除
  def destroys
    deleted = 0
    params.require(:message).permit(messages: [:permit])[:messages].each do |id, item|
      if ActiveRecord::Type::Boolean.new.cast(item[:permit])
        @message = Message.find(id)
        only_admin_send_or_destinate
        @message.destroy
        deleted += 1
      end
    end

    if deleted > 0
      flash[:success] = "メッセージを#{deleted}件削除しました。"
    end
    
    redirect_to current_user
  end
  
  private
    def message_params
      params.require(:message).permit(:user_id, :text)
    end
    
    def set_message
      @message = Message.find(params[:id])
    end
    
    def only_admin_send_or_destinate
      if current_user != send_user(@message) && current_user != destinate_user(@message) && !current_user.admin?
        flash[:danger] = "権限がありません。"
        redirect_to current_user
      end
    end
end
