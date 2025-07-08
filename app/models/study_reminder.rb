class StudyReminder < ApplicationRecord
  belongs_to :user
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :start_time_must_be_in_the_future
  validate :end_time_must_be_after_start_time

  validate :start_and_end_time_must_be_different

  private


  def start_time_must_be_in_the_future
    if start_time.present? && start_time < Time.current
      errors.add(:start_time, "現在の時間以降で設定してください")
    end
  end

  def end_time_must_be_after_start_time
    if start_time.present? && end_time.present? && end_time <= start_time
      errors.add(:end_time, "終了時間は開始時間より後に設定してください")
    end
  end

  def start_and_end_time_must_be_different
    if start_time.present? && end_time.present? && start_time == end_time
      errors.add(:end_time, "学習開始時間と学習終了時間が同じです。時間を変更してください")
    end
  end
end
