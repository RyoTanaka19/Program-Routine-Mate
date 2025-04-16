class AddStudyReminderIdToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :study_reminder_id, :integer
    add_index :study_logs, :study_reminder_id
    add_foreign_key :study_logs, :study_reminders
  end
end
