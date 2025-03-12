class CreateUserStudyBadges < ActiveRecord::Migration[7.2]
  def change
    create_table :user_study_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :study_badge, null: false, foreign_key: true
      t.datetime :earned_at

      t.timestamps
    end
  end
end
