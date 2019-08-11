class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :name_reading
      t.string :email
      t.integer :slot #申請枠の種類
      

      t.timestamps
    end
  end
end
