class LearningComment < ApplicationRecord
  belongs_to :user
  belongs_to :study_log

  validates :text, presence: true
end
