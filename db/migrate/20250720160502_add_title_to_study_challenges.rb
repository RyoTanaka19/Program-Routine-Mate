class AddTitleToStudyChallenges < ActiveRecord::Migration[7.2]
  def change
    add_column :study_challenges, :title, :string
  end
end
