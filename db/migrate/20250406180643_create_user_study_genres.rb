class CreateUserStudyGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :user_study_genres do |t|
      t.references :user, null: false, foreign_key: true
      t.references :study_genre, null: false, foreign_key: true

      t.timestamps
    end
  end
end
