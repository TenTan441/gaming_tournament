class Character < ApplicationRecord
  belongs_to :user
  
  enum game_title: { "ニンテンドウオールスター！大乱闘スマッシュブラザーズ": 0, "大乱闘スマッシュブラザーズDX": 1, "大乱闘スマッシュブラザーズX": 2, "大乱闘スマッシュブラザーズ for Nintendo 3DS": 3, "大乱闘スマッシュブラザーズ for Wii U": 4, "大乱闘スマッシュブラザーズ SPECIAL": 5 }
  validates :game_title, presence: true
  validates :main_character, presence: true
end
