class CreateLearningComments < ActiveRecord::Migration[7.2]
  def change
    create_table :learning_comments do |t|
      t.references :study_log, foreign_key: true
      t.text :text, null: false
      t.timestamps
    end
  end
end
