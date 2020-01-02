class CharactersController < ApplicationController
  
  def select_titles
    title = params[:character][:game_title]
    @character = Character.find_by(game_title: title, user_id: params[:user_id])
    case title
      when 'ニンテンドウオールスター！大乱闘スマッシュブラザーズ'
        @characters = CharacterImage.where(one:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズDX'  
        @characters = CharacterImage.where(two:   true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズX'
        @characters = CharacterImage.where(three: true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズ for Nintendo 3DS', '大乱闘スマッシュブラザーズ for Wii U'
        @characters = CharacterImage.where(four:  true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      when '大乱闘スマッシュブラザーズ SPECIAL'
        @characters = CharacterImage.where(five:  true).map { |fi| [fi.name, fi.id, { 'data-img-src' => "/Character/#{fi.image}.png"}] }
      else
        @characters = nil
    end
  end
  
  def new
    @character = Character.new
  end
  
  def create
    title = Character.game_titles[params[:character][:game_title]]
    main = params[:main_character][:character_id]
    sub_characters = params[:sub_characters][:character_ids]
    user = params[:user_id]
    characters = []
    sub_characters.each do |subs|
      unless subs.blank?
        characters.push(subs)
      end
    end
    @character = Character.new(game_title: title, main_character: main, sub_character1: characters[0], sub_character2: characters[1], sub_character3: characters[2], user_id: user)
    if @character.save
      flash[:success] = "新規作成しました"
      redirect_to new_user_character_path
    else
      flash[:danger] = "作成に失敗しました"
      render :edit
    end
  end
  
  
  # editページで
  def edit
    @character = Character.new
  end
  
  def update
    title = params[:character][:game_title]
    main = params[:main_character][:character_id]
    sub_characters = params[:sub_characters][:character_ids]
    user = params[:user_id]
    @user = User.find(user)
    characters = []
    sub_characters.each do |subs|
      unless subs.blank?
        characters.push(subs)
      end
    end
    
    @character = Character.find_by(game_title: title, user_id: user)
    
    if @character.nil? # 新規作成
      @character = Character.new(game_title: title, main_character: main, sub_character1: characters[0], sub_character2: characters[1], sub_character3: characters[2], user_id: user)
      if @character.save
        flash[:success] = "新規作成しました"
      else
        flash[:danger] = "作成に失敗しました"
      end
    else #更新
      if @character.update_attributes(main_character: main, sub_character1: characters[0], sub_character2: characters[1], sub_character3: characters[2])
        flash[:success] = "更新に成功しました"
      else
        flash[:danger] = "更新に失敗しました"
      end
    end
    
    redirect_to @user
  end
end
