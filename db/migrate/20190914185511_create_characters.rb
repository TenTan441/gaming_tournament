class CreateCharacters < ActiveRecord::Migration[5.1]
  def change
    create_table :characters do |t|
      t.integer :game_title
      t.integer :main_character
      t.integer :sub_character1
      t.integer :sub_character2
      t.integer :sub_character3
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
