class AddHoldThirdPlaceMatchToTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :hold_third_place_match, :boolean, default: false, null: false
  end
end
