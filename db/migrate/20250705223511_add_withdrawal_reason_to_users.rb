class AddWithdrawalReasonToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :withdrawal_reason, :text
  end
end
