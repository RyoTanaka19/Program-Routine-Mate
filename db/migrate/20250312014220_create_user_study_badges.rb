class CreateUserStudyGenres < ActiveRecord::Migration[6.0]
  def change
    create_table :user_study_genres do |t|
      t.integer :user_id
      t.integer :study_genre_id

      t.timestamps
    end
  end
end
