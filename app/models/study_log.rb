class StudyLog < ApplicationRecord
  mount_uploader :image, StudyLogsImageUploader
  belongs_to :user
  has_many :learning_comments, dependent: :destroy
end
