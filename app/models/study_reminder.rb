class StudyReminder < ApplicationRecord
  validates :start_time, presence: true   # 開始時刻が必須
  validates :end_time, presence: true     # 終了時刻も必須
end
