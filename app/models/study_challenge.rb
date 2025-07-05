class StudyChallenge < ApplicationRecord
  has_many :study_answers, dependent: :destroy
  belongs_to :study_log
end
