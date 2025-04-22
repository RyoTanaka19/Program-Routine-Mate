class AddUserIdToLearningComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :learning_comments, :user, null: false, foreign_key: true
  end
end
