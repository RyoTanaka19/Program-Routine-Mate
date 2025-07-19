class RemoveStudyingContinuationSystematizationFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :studying_continuation_systematization, :text
  end
end
