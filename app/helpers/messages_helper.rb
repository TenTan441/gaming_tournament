module MessagesHelper
    
  def send_user(message)
    return User.find(message.user_id)
  end
  
  def destinate_user(message)
    return User.find(message.user_to)
  end
end
