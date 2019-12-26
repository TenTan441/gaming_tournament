class AddTournamentPrivateToTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :private, :boolean, default: false, null: false
  end
end
