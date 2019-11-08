class User < ApplicationRecord
  before_save { self.email = email.downcase } unless :twitter_auth?
  
  validates :name,  presence: true, length: { maximum: 50 }
  has_secure_password validations: false
  
  mount_uploader :image, PictureUploader
  
  with_options if: :email_auth? do
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 100 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
    
    validates :password, presence: true, 
                         length: { minimum: 6 }, 
                         allow_nil: true
  end
  
  # twitter認証ではhas_secure_passwordのバリデーション機能をoffにする必要がある
  with_options if: :twitter_auth? do
    validates :provider, presence: true
    validates :uid, presence: true
  end
  
  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.find_or_create_from_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    #nickname = auth[:info][:nickname]
    name = auth[:info][:name]
    twitter_url = auth[:info][:urls][:Twitter]
    #image_url = auth[:info][:image]
    #description = auth[:info][:description]
    
    self.find_or_create_by(provider: provider, uid: uid) do |user|
      #user.nickname = nickname
      user.name = name
      user.twitter_url = twitter_url
      #user.description = description
    end
  end
  
  #email認証「A」かTwitter認証「B」のどちらかを済ませていればどちらかは空白でも構わない
  # A || B を満たせれば良い
  private

    def email_auth?
      return true if (email.present? && password.present? && password_digest.present?)
      false
    end
    
    def twitter_auth?
      return true if (provider.present? && uid.present?)
      false
    end
end
