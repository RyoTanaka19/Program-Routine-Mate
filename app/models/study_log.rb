class StudyLog < ApplicationRecord
  mount_uploader :image, StudyLogsImageUploader
  belongs_to :user
  belongs_to :study_genre
  belongs_to :study_reminder, optional: true
  after_create :assign_badges
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :learning_comments, dependent: :destroy
  validates :content, presence: true
  validates :text, presence: true
  validates :date, presence: true
def self.ransackable_attributes(auth_object = nil)
  super + [ "content", "study_genre_id" ]
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
    current_time = Time.current

    unless current_time >= start_time && current_time <= end_time
      self.total = nil
      return
    end

    elapsed_seconds = (current_time - start_time).to_i

    self.total = elapsed_seconds > 0 ? elapsed_seconds : nil
  end


  def assign_badges
    if user.study_logs.count == 1
      StudyBadgeService.new(user).assign_first_study_log_badge
    end
  end
end
