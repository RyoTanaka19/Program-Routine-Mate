class AddStudyingSessionReferenceToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_reference :study_logs, :studying_session, foreign_key: true
  end
end
