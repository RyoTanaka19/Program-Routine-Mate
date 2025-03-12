class StudyBadge < ApplicationRecord
  has_many :user_study_badges
  has_many :users, through: :user_study_badges
end
