class AddStudyGenreToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_reference :study_logs, :study_genre, null: true, foreign_key: true
  end
end
