class StudyLog < ApplicationRecord
  belongs_to :user
  mount_uploader :image, StudyLogsImageUploader
  has_many :learning_comments, dependent: :destroy

  # 学習内容 空なし
  validates :content, presence: true
  # 学習時間 空なし
  validates :hour, presence: true
  validates :minute, presence: true
  validates :second, presence: true
  # 学んだこと 空なし
  validates :text, presence: true
end
