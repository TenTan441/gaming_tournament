class Tournament < ApplicationRecord
  validates :name, presence: true, length: { maximum: 60 }
  validates :master, presence: true
  validates :id_number, presence: true
  validates :url, format: { with: /\A[a-zA-Z\d]+\z/ }, presence: true
  validates :elimination_type, presence: true
  validates :start_time, presence: true
  has_many :participants, dependent: :destroy
  enum game_title: { "ニンテンドウオールスター！大乱闘スマッシュブラザーズ": "Super Smash Bros.", "大乱闘スマッシュブラザーズDX": "Super Smash Bros. Melee", "大乱闘スマッシュブラザーズX": "Super Smash Bros. Brawl", "大乱闘スマッシュブラザーズ for Nintendo 3DS": "Super Smash Bros. for 3DS", "大乱闘スマッシュブラザーズ for Wii U": "Super Smash Bros. for Wii U", "大乱闘スマッシュブラザーズ SPECIAL": "Super Smash Bros. Ultimate" }
  
  # 開始時間に過去日は設定不可
  def start_time_cannot_be_in_the_past
    if start_time.present? && start_time < created_at
      errors.add(:start_time, "は過去の日付に設定できません。")
    end
  end
end
