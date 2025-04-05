class AddForeignKeysToStudyingSessions < ActiveRecord::Migration[7.2]
  def change
    add_reference :studying_sessions, :study_logs, foreign_key: true
    add_reference :studying_sessions, :user, foreign_key: true
  end
end
