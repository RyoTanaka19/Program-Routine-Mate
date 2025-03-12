class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  has_many :likes, dependent: :destroy
  has_many :liked_study_logs, through: :likes, source: :study_log

  has_many :study_logs, dependent: :destroy

  has_many :user_study_badges
  has_many :study_badges, through: :user_study_badges
  # ユーザーが削除されると学習コメントも削除される
  has_many :learning_comments, dependent: :destroy

  # 名前 空はなし、一意性
  validates :name, presence: true, uniqueness: true
  # 名前 メールアドレス 空はなし、一意性
  validates :email, presence: true, uniqueness: true
  # パスワード 空はなし
  validates :password, presence: true
  # パスワード確認 空はなし
  validates :password_confirmation, presence: true
  # パスワードとパスワード確認が一致するかどうか確認
  validates :password, confirmation: { message: "が一致しません" }

  # 特定のコメントが現在ログインしているユーザーが投稿したものであるかどうか判定
  def own?(object)
    id == object&.user_id
  end

  def self.studied_logs_days_ranking
    StudyLog
      .select(Arel.sql("user_id, COUNT(DISTINCT DATE(study_day)) AS posted_days_count"))
      .group(:user_id)
      .order(Arel.sql("posted_days_count DESC"))
  end
end
