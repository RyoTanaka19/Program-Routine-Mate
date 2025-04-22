class ChangeTextNullOnLearningComments < ActiveRecord::Migration[7.2]
  def change
    change_column_null :learning_comments, :text, true
  end
end
