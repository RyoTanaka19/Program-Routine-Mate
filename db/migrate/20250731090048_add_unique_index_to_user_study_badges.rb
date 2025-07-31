class AddUniqueIndexToUserStudyBadges < ActiveRecord::Migration[7.2]
  def change
    add_index :user_study_badges, [:user_id, :study_badge_id], unique: true
  end
end
