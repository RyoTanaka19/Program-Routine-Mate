class AddProfileToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :profile, :string
  end
end
