class Message < ApplicationRecord
  belongs_to :user, optional: true
  
  validates :user_to, presence: true
  validates :text, presence: true
  
  scope :inbox,       -> (user, messages) { where(user_to: user.id)
                                            .from_search(messages[:user_id])
                                            .text_search(messages[:text])
                                            .edited_at_search(messages[:from], messages[:to])
                                            .order(edited_at: "DESC")
                                            .paginate(page: messages[:inbox_page], per_page: 10) }
  scope :inbox_page,  -> (user, messages) { where(user_to: user.id)
                                            .order(edited_at: "DESC")
                                            .paginate(page: messages[:indox_page], per_page: 10) }
  scope :outbox,      -> (user, messages) { where(user_id: user.id)
                                            .to_search(messages[:user_to])
                                            .text_search(messages[:text])
                                            .edited_at_search(messages[:from], messages[:to])
                                            .order(edited_at: "DESC")
                                            .paginate(page: messages[:outbox_page], per_page: 10) }
  scope :outbox_page, -> (user, messages) { where(user_id: user.id)
                                            .order(edited_at: "DESC")
                                            .paginate(page: messages[:outbox_page], per_page: 10) }
                                      
  
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
  def self.edited_at_search(from, to)
    if !from.blank? && !to.blank?
      from = DateTime.parse(from + " +09:00")
      to = DateTime.parse(to + " +09:00")
      where('edited_at BETWEEN ? AND ?', from, to)
    elsif !from.blank?
      from = DateTime.parse(from + " +09:00")
      where('edited_at >= ?', from)
    elsif !to.blank?
      to = DateTime.parse(to + " +09:00")
      where('edited_at <= ?', to)
    else
      all
    end
  end
end
