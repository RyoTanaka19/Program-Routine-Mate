class AddOgpToStudyLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :study_logs, :ogp, :string
  end
end
