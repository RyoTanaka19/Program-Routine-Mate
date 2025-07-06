class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[google_oauth2 line github]

  validates :uid, uniqueness: { scope: :provider }

def self.from_omniauth(auth)
  # まずはproviderとuidでユーザーを検索
  user = find_by(provider: auth.provider, uid: auth.uid)

  return user if user.present?

  # 次にメールアドレスでユーザーを探す（メールがあれば）
  if auth.info.email.present?
    user = find_by(email: auth.info.email)

    if user.present?
      # 既存ユーザーにproviderとuidをセットして更新する
      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end
  end

  # どちらにも該当しなければ新規作成
  create do |user|
    user.provider = auth.provider
    user.uid = auth.uid

    if auth.info.email.present?
      user.email = auth.info.email
    else
      user.email = "#{auth.uid}-#{auth.provider}@example.com"
    end

    user.password = Devise.friendly_token[0, 20]
    user.password_confirmation = user.password
    user.name = auth.info.name.presence || "No Name"
  end
end


  def social_profile(provider)
    social_profiles.select { |sp| sp.provider == provider.to_s }.first
  end

  def set_values(omniauth)
    return if provider.to_s != omniauth["provider"].to_s || uid != omniauth["uid"]

    credentials = omniauth["credentials"]
    info = omniauth["info"]

    access_token = credentials["refresh_token"]
    access_secret = credentials["secret"]
    credentials = credentials.to_json
    name = info["name"]
  end

  def set_values_by_raw_info(raw_info)
    self.raw_info = raw_info.to_json
    self.save!
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


  validates :password, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :password, confirmation: { message: "が一致しません" }, on: :create, unless: :from_oauth?
  validates :password, confirmation: true

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
end
