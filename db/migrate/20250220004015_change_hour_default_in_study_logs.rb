class ChangeHourDefaultInStudyLogs < ActiveRecord::Migration[7.2]
  def change
    change_column_default :study_logs, :hour, 0
  end
end
