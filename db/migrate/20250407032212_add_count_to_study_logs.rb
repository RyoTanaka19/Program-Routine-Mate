class AddCountToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :count, :integer
  end
end
