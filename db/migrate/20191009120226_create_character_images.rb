class CreateCharacterImages < ActiveRecord::Migration[5.1]
  def change
    create_table :character_images do |t|
      t.string :name
      t.string :image
      t.boolean :one, default: false, null: false
      t.boolean :two, default: false, null: false
      t.boolean :three, default: false, null: false
      t.boolean :four, default: false, null: false
      t.boolean :five, default: true, null: false
      t.timestamps
    end
  end
end
