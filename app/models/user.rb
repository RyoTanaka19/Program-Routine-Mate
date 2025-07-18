class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[google_oauth2 line github]

  validates :uid, uniqueness: { scope: :provider }

def self.from_omniauth(auth)
  user = find_by(provider: auth.provider, uid: auth.uid)

  return user if user.present?


  if auth.info.email.present?
    user = find_by(email: auth.info.email)

    if user.present?

      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end
  end


create do |user|
  user.provider = auth.provider
  user.uid = auth.uid
  user.email = auth.info.email.presence || "#{auth.uid}-#{auth.provider}@example.com"
  user.password = Devise.friendly_token[0, 20]
  user.password_confirmation = user.password
  user.name = auth.info.name.presence || "Guest"
  end
end



  mount_uploader :profile_image, ProfileImageUploader
  has_many :likes, dependent: :destroy
  has_many :liked_study_logs, through: :likes, source: :study_log
  has_many :study_logs, dependent: :destroy
  has_many :study_reminders, dependent: :destroy
  has_many :user_study_badges, dependent: :destroy
  has_many :study_badges, through: :user_study_badges
  has_many :learning_comments, dependent: :destroy
  has_many :study_genres, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  attr_accessor :skip_password_validation
  validates :password, presence: true, on: :create, unless: :skip_password_validation
  validates :password_confirmation, presence: true, on: :create, unless: :skip_password_validation
  validates :password, confirmation: { message: "が一致しません" }, on: [ :create, :update ], unless: :skip_password_validation
  validates :password_confirmation, presence: true, on: [ :create, :update ], unless: :skip_password_validation

def from_oauth?
  from_google_oauth? || from_line_oauth? || from_github_oauth?
end

  def from_google_oauth?
    provider == "google_oauth2"
  end

  def from_line_oauth?
    provider == "line"
  end

  def from_github_oauth?
  provider == "github"
end

  def own?(object)
    id == object&.user_id
  end

  def can_add_new_genre?
    study_settings.count < 3 && study_settings.any?(&:completed_21_days?)
  end

  def self.studied_logs_days_ranking
    StudyLog
      .select(Arel.sql("user_id, COUNT(DISTINCT DATE(date)) AS posted_days_count"))
      .group(:user_id)
      .order(Arel.sql("posted_days_count DESC"))
  end

  def reload_contribution_graph_data
  study_logs
    .group("DATE(created_at)")
    .order("DATE(created_at)")
    .count
    .map { |date, total| { date: date.to_s, total: total } }
  end
end
