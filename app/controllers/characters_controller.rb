class CharactersController < ApplicationController
  def new
    @character = Character.new
    @main_character_64 = CharacterImage.where(one:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
    @main_character_DX = CharacterImage.where(two:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
    @main_character_X  = CharacterImage.where(three: true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
    @main_character_for= CharacterImage.where(four:  true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
    @main_character_SP = CharacterImage.where(five:  true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
  end
  
  def create
    debugger
    flash[:success] = "新規作成しました"
    redirect_to new_user_character_path
  end
end
