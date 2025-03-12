class UserStudyBadge < ApplicationRecord
  belongs_to :user
  belongs_to :study_badge
end
