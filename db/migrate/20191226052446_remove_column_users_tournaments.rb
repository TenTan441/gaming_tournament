class RemoveColumnUsersTournaments < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :slot, :integer
    remove_column :users, :onesignal_id, :integer
    remove_column :users, :name_reading, :string
    remove_column :tournaments, :elimination_type, :string
    remove_column :tournaments, :url, :string
    remove_column :tournaments, :master, :integer
    remove_column :tournaments, :group_stage_enabled, :boolean
    remove_column :tournaments, :hold_third_place_match, :boolean
    remove_column :messages, :read, :boolean
    remove_column :messages, :show, :boolean
  end
end
