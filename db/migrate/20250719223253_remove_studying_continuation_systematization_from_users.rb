# db/migrate/20250719223253_remove_studying_continuation_systematization_from_users.rb
class RemoveStudyingContinuationSystematizationFromUsers < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:users, :studying_continuation_systematization)
      remove_column :users, :studying_continuation_systematization, :text
    end
  end
end
