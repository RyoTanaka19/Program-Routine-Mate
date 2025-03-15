class AddColumnToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :name, :string
    add_column :users, :profile_image, :string
    add_column :users, :self_introduction, :text
  end
end
