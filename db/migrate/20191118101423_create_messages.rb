class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :user_to
      t.boolean :read, default: false, null: false # 受信側の既読設定
      t.boolean :show, default: true, null: false # 送信側の表示設定
      t.text :text
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
