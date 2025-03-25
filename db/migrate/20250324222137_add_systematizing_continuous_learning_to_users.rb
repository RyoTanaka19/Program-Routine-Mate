class AddSystematizingContinuousLearningToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :systematizing_continuous_learning, :text
  end
end
