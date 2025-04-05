class StudyLog < ApplicationRecord
  belongs_to :user
  after_create :assign_badges
  mount_uploader :image, StudyLogsImageUploader
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :learning_comments, dependent: :destroy
  belongs_to :studying_session
  belongs_to :user

  # 学習内容 空なし
  validates :content, presence: true
  # 学んだこと 空なし
  validates :text, presence: true
  validates :genre, presence: true, uniqueness: true
  validates :study_day, presence: true
  validates :date, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Ransackで検索可能な属性（カラム）
  def self.ransackable_attributes(auth_object = nil)
    [ "content" ]
  end
  private

  def assign_badges
    if user.study_logs.count == 1
      StudyBadgeService.new(user).assign_first_study_log_badge
    end
  end
end
