class CharactersController < ApplicationController
  def new
    @character = Character.new
    @main_character_64 = CharacterImage.where(one:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
  end
  
  def select_titles
    title = params[:character][:game_title]
    case title
      when 'ニンテンドウオールスター！大乱闘スマッシュブラザーズ'
        @characters = CharacterImage.where(one:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズDX'  
        @characters = CharacterImage.where(two:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズX'
        @characters = CharacterImage.where(three:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズ for Nintendo 3DS', '大乱闘スマッシュブラザーズ for Wii U'
        @characters = CharacterImage.where(four:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズ SPECIAL'
        @characters = CharacterImage.where(five:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
    end
  end
  
  def create
    title = Character.game_titles[params[:character][:game_title]]
    main = params[:main_character][:character_id]
    user = params[:user_id]
    @character = Character.new(game_title: title, main_character: main, user_id: user)
    if @character.save
      flash[:success] = "新規作成しました"
      redirect_to new_user_character_path
    else
      flash[:danger] = "作成に失敗しました"
      render :new
    end
  end
end
