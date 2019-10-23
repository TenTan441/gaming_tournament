module CharactersHelper
  
  def characterimage_from_character(character)
    return CharacterImage.find(character).image
  end
end
