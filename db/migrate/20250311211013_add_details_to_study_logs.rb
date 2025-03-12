class AddDetailsToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :genre, :string
    add_column :study_logs, :study_day, :date
    add_column :study_logs, :start_time, :time
    add_column :study_logs, :end_time, :time
  end
end
