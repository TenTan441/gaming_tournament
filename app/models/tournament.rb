class Tournament < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }
  validates :master, presence: true
  validates :id_number, presence: true
  #validates :url, format: { with: /\A[a-zA-Z\d]+\z/ }, presence: true
  #validates :elimination_type, presence: true
  validates :start_time, presence: true
  has_many :participants, foreign_key: :tournament_id, dependent: :destroy
  belongs_to :user, optional: true
  enum status: {"準備中": 0, "進行中": 1, "完了": 2}
  enum game_title: { "大乱闘スマッシュブラザーズ64": 0, "大乱闘スマッシュブラザーズDX": 1, "大乱闘スマッシュブラザーズX": 2, "大乱闘スマッシュブラザーズ for Nintendo 3DS": 3, "大乱闘スマッシュブラザーズ for Wii U": 4, "大乱闘スマッシュブラザーズ SPECIAL": 5 }

  # 開始時間に過去日は設定不可
  def start_time_cannot_be_in_the_past
    if start_time.present? && start_time < created_at
      errors.add(:start_time, "は過去の日付に設定できません。")
    end
  end
  
  def self.name_search(names)
    if !names.blank?
      where(['name LIKE ?', "%#{names}%"])
    else
      all
    end
  end
  
  # 開催者の検索
  def self.master_search(master)
    if !master.blank?
      where(['master = ?', "#{master}"])
    else
      all
    end
  end
  
  # タイトルの検索
  def self.title_search(title)
    if !title.blank?
      where(game_title: title)
    else
      all
    end
  end
  
  # 大会ステータスの検索
  def self.status_search(state)
    if !state.blank?
      where(status: state)
    else
      all
    end
  end
  
  # 大会開始時刻の検索
  def self.start_time_search(from, to)
    if !from.blank? && !to.blank?
      from = DateTime.parse(from + " +09:00")
      to = DateTime.parse(to + " +09:00")
      where('start_time BETWEEN ? AND ?', from, to)
    elsif !from.blank?
      from = DateTime.parse(from + " +09:00")
      where('start_time >= ?', from)
    elsif !to.blank?
      to = DateTime.parse(to + " +09:00")
      where('start_time <= ?', to)
    else
      all
    end
  end
end
