class AddStudyingContinuationSystematizationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :studying_continuation_systematization, :text
  end
end
