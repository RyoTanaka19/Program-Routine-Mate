class CreateStudyAnswers < ActiveRecord::Migration[7.2]
  def change
    create_table :study_answers do |t|
      t.references :study_challenge, null: false, foreign_key: true
      t.string :user_answer
      t.string :correct_answer
      t.text :explanation
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
