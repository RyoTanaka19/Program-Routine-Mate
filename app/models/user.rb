class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[google_oauth2 line]

         def self.from_omniauth(auth)
          where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
            user.email = auth.info.email
            user.name = auth.info.name
            user.password = Devise.friendly_token[0, 20] if user.new_record?
            user.password_confirmation = Devise.friendly_token[0, 20] if user.new_record?
            user.save!
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


  has_many :likes, dependent: :destroy
  has_many :liked_study_logs, through: :likes, source: :study_log

  has_many :study_logs, dependent: :destroy

  has_many :user_study_badges
  has_many :study_badges, through: :user_study_badges
  # ユーザーが削除されると学習コメントも削除される
  has_many :learning_comments, dependent: :destroy

  has_many :suggests
  mount_uploader :profile_image, ProfileImageUploader

  has_many :studying_sessions

  # 名前 空はなし、一意性
  validates :name, presence: true
  # 名前 メールアドレス 空はなし、一意性
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # パスワード 空はなし
  validates :password, presence: true, on: :create
  # パスワード確認 空はなし
  validates :password_confirmation, presence: true, on: :create
  # パスワードとパスワード確認が一致するかどうか確認
  validates :password, confirmation: { message: "が一致しません" }, on: :create, unless: :from_google_oauth?



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

  def from_google_oauth?
    provider == "google_oauth2"
  end
end
