class AddTournamentStatusToTournament < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :status, :string
  end
end
