class AddSecondToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :second, :integer, null:false
  end
end
