class RenamePromptAndResponseInStudyChallenges < ActiveRecord::Migration[7.2]
  def change
    rename_column :study_challenges, :prompt, :ai_question
    rename_column :study_challenges, :response, :user_response
  end
end
