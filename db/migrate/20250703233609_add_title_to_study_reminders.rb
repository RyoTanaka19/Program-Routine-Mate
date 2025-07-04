class AddTitleToStudyReminders < ActiveRecord::Migration[7.2]
  def change
    add_column :study_reminders, :title, :string
  end
end
