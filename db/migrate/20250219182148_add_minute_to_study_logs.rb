class AddMinuteToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :minute, :integer, null:false
  end
end
