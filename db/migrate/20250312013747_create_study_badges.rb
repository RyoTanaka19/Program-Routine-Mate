class CreateStudyBadges < ActiveRecord::Migration[7.2]
  def change
    create_table :study_badges do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :icon, null: false

      t.timestamps
    end
  end
end
