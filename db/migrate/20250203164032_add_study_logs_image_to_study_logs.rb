class AddStudyLogsImageToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :image, :string
  end
end
