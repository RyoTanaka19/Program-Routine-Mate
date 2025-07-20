class StudyLog < ApplicationRecord
  mount_uploader :image, StudyLogsImageUploader
  belongs_to :user
  belongs_to :study_genre
  belongs_to :study_reminder, optional: true
  has_many :study_likes, dependent: :destroy
  has_many :study_liked_users, through: :study_likes, source: :user
  has_many :study_comments, dependent: :destroy
  has_many :study_challenges, dependent: :destroy

  validates :content, presence: true
  validates :text, presence: true
  validates :date, presence: true

  before_create :calculate_study_duration

  # バッジ付与をStudyBadgeServiceに委譲
  after_create :assign_badges

  def self.ransackable_attributes(auth_object = nil)
    super + [ "content", "study_genre_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    super + [ "study_genre" ]
  end

  private

  # 学習時間を計算して、totalに保存する
  def calculate_study_duration
    return unless study_reminder.present? && study_reminder.start_time.present? && study_reminder.end_time.present?

    start_time = study_reminder.start_time
    end_time = study_reminder.end_time
    current_time = Time.current

    unless current_time >= start_time && current_time <= end_time
      self.total = nil
      return
    end

    elapsed_seconds = (current_time - start_time).to_i
    self.total = elapsed_seconds > 0 ? elapsed_seconds : nil
  end

  # バッジをStudyBadgeServiceに委譲
  def assign_badges
    StudyBadgeService.new(user).assign_badges
  end
end
