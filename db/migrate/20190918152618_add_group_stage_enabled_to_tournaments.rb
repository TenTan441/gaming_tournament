class AddGroupStageEnabledToTournaments < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :group_stage_enabled, :boolean
  end
end
