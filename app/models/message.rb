class Message < ApplicationRecord
  belongs_to :user
  
  validates :user_to, presence: true
  validates :text, presence: true
  
  # 宛名ユーザIDが含まれる場合は合致するメッセージを返し、含まれてない場合は全てのメッセージを返します。
  def self.from_search(user)
    if !user.blank?
      where(['user_id = ?', "#{user}"])
    else
      all
    end
  end
  
  # 差出人の検索
  def self.to_search(user)
    if !user.blank?
      where(['user_to = ?', "#{user}"])
    else
      all
    end
  end
  
  # 本文の検索
  def self.text_search(search)
    if search
      where(['text LIKE ?', "%#{search}%"])
    else
      all
    end
  end
  
  # 更新日時の検索
  def self.updated_at_search(from, to)
    if !from.blank? && !to.blank?
      where('updated_at BETWEEN ? AND ?', from, to)
    elsif !from.blank?
      where('updated_at >= ?', from)
    elsif !to.blank?
      where('updated_at <= ?', to)
    else
      all
    end
  end
end
