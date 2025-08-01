class RenameTotalToTotalStudyTimeInStudyLogs < ActiveRecord::Migration[7.2]
  def change
    rename_column :study_logs, :total, :total_study_time
  end
end
