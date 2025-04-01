class CreateStudyingSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :studying_sessions do |t|
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
