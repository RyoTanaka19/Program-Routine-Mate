class AddDateAndTotalToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :date, :date
    add_column :study_logs, :total, :integer
  end
end
