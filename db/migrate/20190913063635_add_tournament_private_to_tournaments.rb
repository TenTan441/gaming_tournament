class AddTournamentPrivateToTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :private, :boolean, default: true, null: false
  end
end
