class StudyLog < ApplicationRecord
  belongs_to :user
  mount_uploader :image, StudyLogsImageUploader
  has_many :learning_comments, dependent: :destroy
end
