class StudyingSession < ApplicationRecord
  belongs_to :user  # ユーザーとの関連付け
  has_many :study_logs  # 学習ログとの関連付け
end
