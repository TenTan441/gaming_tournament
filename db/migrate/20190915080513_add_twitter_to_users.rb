class AddTwitterToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :twitter_url, :string
    add_column :users, :twitter_private, :boolean, default: true, null: false
  end
end
