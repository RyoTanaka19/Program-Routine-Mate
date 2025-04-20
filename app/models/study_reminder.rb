class StudyReminder < ApplicationRecord
  belongs_to :user

  def as_calendar_event
    {
      title: "学習時間",
      start: start_time.iso8601,
      end: end_time.iso8601
    }
  end

  # バリデーション（任意）
  validates :start_time, presence: true
  validates :end_time, presence: true
end
