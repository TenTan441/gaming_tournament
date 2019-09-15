class CreateParticipants < ActiveRecord::Migration[5.1]
  def change
    drop_table :participants
    
    create_table :participants do |t|
      t.integer :user_id
      t.integer :ranking
      t.references :tournament, foreign_key: true

      t.timestamps
    end
  end
end
