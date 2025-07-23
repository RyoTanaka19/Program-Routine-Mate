class StudyAnswer < ApplicationRecord
  belongs_to :study_challenge
  belongs_to :user
  validates :user_answer, presence: { message: 'を選択してください' }
end
