class UserStudyGenre < ApplicationRecord
  belongs_to :user
  belongs_to :study_genre
end
