class CreateLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :study_log, null: false, foreign_key: true

      t.timestamps
    end
    add_index :likes, [:user_id, :study_log_id], unique: true
  end
end
