class AddGrassColorToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :grass_color, :string
  end
end
