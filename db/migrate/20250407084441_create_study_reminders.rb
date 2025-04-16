class CreateStudyReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :study_reminders do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
