class CreateStudyLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :study_logs if_not_exists: true do |t|
      t.string :content, null: false
      t.integer :hour, null: false
      t.text :text, null: false
      t.timestamps
    end
  end
end
