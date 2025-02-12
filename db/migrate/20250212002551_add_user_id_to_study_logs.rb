class AddUserIdToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_reference :study_logs, :user, foreign_key: true
  end
end
