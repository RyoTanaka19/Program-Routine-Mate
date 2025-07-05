class CreateStudyChallenges < ActiveRecord::Migration[7.2]
  def change
    create_table :study_challenges do |t|
      t.references :study_log, null: false, foreign_key: true
      t.text :prompt
      t.text :response

      t.timestamps
    end
  end
end
