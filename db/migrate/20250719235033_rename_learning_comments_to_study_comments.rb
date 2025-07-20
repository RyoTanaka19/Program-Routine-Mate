class RenameLearningCommentsToStudyComments < ActiveRecord::Migration[7.2]
  def change
    rename_table :learning_comments, :study_comments
  end
end
