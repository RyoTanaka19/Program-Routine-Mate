class RenameLikesToStudyLikes < ActiveRecord::Migration[7.2]
  def change
    rename_table :likes, :study_likes
  end
end
