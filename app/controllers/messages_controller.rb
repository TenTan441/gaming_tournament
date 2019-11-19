class MessagesController < ApplicationController
  
  before_action :set_message, except: :create
  before_action :only_send_or_destinate, except: :create
  #after_action :to_current_user, only: [:create, :update, :destroy]
  
  UPDATE_SUCCESS_MSG = "ステータスを変更しました"
  UPDATE_ERROR_MSG = "ステータスの変更に失敗しました。"
  
  def create
    message = Message.new(message_params)
    message.user_to = params[:user_to]
    
    if message.save
      flash[:success] = "メッセージを送信しました。"
    else
      flash[:danger] = "メッセージ送信に失敗しました。"
    end
    redirect_to current_user
  end
  
  def edit
    @user = send_user(@message)
  end
  
  def update
    
    if params[:read].present?
      @message.read = params[:read]
      if @message.save
        flash[:success] = UPDATE_SUCCESS_MSG
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif params[:show].present?
      @message.show = params[:show]
      if @message.save
        flash[:success] = UPDATE_SUCCESS_MSG
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    else
      if @message.update_attributes(message_params)
        flash[:success] = "メッセージを更新しました。"
      else
        flash[:danger] = "更新に失敗しました。"
      end
    end
    redirect_to current_user
  end
  
  def destroy
    @message.destroy
    flash[:success] = "メッセージを削除しました。"
    redirect_to current_user
  end
  
  private
    def message_params
      params.require(:message).permit(:user_id, :text)
    end
    
    def set_message
      @message = Message.find(params[:id])
    end
    
    def only_send_or_destinate
      unless current_user == send_user(@message) || current_user == destinate_user(@message)
        redirect_to current_user
      end
    end
    
    # 何故かこのアクションを呼び出すとエラー発生する。原因は謎。エラー文はDoubleRenderError (Render and/or redirect were called multiple times in this action.
    #def to_current_user
    #  redirect_to current_user
    #end
end
