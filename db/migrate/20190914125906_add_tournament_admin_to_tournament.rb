class AddTournamentAdminToTournament < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :master, :integer, presence: true
  end
end
