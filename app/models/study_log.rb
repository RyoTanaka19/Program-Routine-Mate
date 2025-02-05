class StudyLog < ApplicationRecord
  mount_uploader :image, StudyLogsImageUploader

  has_many :learning_comments, dependent: :destroy
end
