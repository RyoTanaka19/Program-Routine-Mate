class StudyLog < ApplicationRecord
  mount_uploader :image, StudyLogsImageUploader
  mount_uploader :ogp, StudyLogsOgpUploader

  belongs_to :user
  belongs_to :study_genre
  belongs_to :study_reminder, optional: true
  after_create :assign_badges

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  has_many :learning_comments, dependent: :destroy


  # 学習内容 空なし
  validates :content, presence: true
  # 学んだこと 空なし
  validates :text, presence: true
  validates :date, presence: true




  # Ransackで検索可能な属性（カラム）
  def self.ransackable_attributes(auth_object = nil)
    [ "content" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    super + [ "study_genre_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    super + [ "study_genre" ]
  end

  before_create :calculate_study_duration


  private

  def calculate_study_duration
    return unless study_reminder.present?
    return unless study_reminder.start_time.present? && study_reminder.end_time.present?

    start_time = study_reminder.start_time
    end_time = study_reminder.end_time

    self.total = ((end_time - start_time) / 60).to_i
  end

  def assign_badges
    if user.study_logs.count == 1
      StudyBadgeService.new(user).assign_first_study_log_badge
    end
  end
end
