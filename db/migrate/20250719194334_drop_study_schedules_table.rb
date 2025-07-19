class DropStudySchedulesTable < ActiveRecord::Migration[7.2]
  def change
     drop_table :study_schedules, if_exists: true
  end
end
