class CreateTournaments < ActiveRecord::Migration[5.1]
  def change
    create_table :tournaments do |t|
      t.integer :id_number
      t.string :name
      t.integer :game_title
      t.string :elimination_type
      t.datetime :start_time
      t.string :url
      t.text :description
      t.references :user, foreign_key: true
      
      t.timestamps
    end
  end
end
