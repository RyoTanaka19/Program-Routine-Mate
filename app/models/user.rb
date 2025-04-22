class User < ApplicationRecord
  # Deviseを使って、ユーザー認証機能を提供
  # 使用するモジュール: データベース認証、新規登録、パスワードリカバリ、ログイン情報の記憶、OAuth認証（Google, LINE）
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[google_oauth2 line github]

  # 同じプロバイダー内でUIDの重複を防ぐ（例: 同じGoogleアカウントは1ユーザーのみ）
  validates :uid, uniqueness: { scope: :provider }

  # SNSログイン用のユーザーを取得または作成する
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      # Google認証とLINE認証で異なる処理をする
      if auth.provider == "google_oauth2"
        user.email = auth.info.email if auth.info.email.present? # Googleの場合はメールがあれば設定
      elsif auth.provider == "line"
        # LINEの場合はメールアドレスが取得できないことがあるので、メールがない場合でもスキップ
        user.email = auth.info.email if auth.info.email.present?
      end

      user.password = Devise.friendly_token[0, 20]      # ランダムなパスワードを自動生成
      user.password_confirmation = user.password        # パスワード確認用にも同じ値を設定
      user.name = auth.info.name                        # プロフィール名を設定
      user.save!                                        # ユーザー情報を保存
    end
  end

  # 指定されたプロバイダーに対応するソーシャルプロフィールを取得
  def social_profile(provider)
    social_profiles.select { |sp| sp.provider == provider.to_s }.first
  end

  # Omniauthから受け取った情報でユーザー情報をセット（現在は保存処理は行っていない）
  def set_values(omniauth)
    return if provider.to_s != omniauth["provider"].to_s || uid != omniauth["uid"]

    credentials = omniauth["credentials"]
    info = omniauth["info"]

    access_token = credentials["refresh_token"]
    access_secret = credentials["secret"]
    credentials = credentials.to_json
    name = info["name"]
  end

  # 外部から取得したraw_infoを保存（JSON形式で）
  def set_values_by_raw_info(raw_info)
    self.raw_info = raw_info.to_json
    self.save!
  end

  # プロフィール画像のアップロード機能を追加（CarrierWave）
  mount_uploader :profile_image, ProfileImageUploader

  # 各種アソシエーションの定義
  has_many :suggests
  has_many :likes, dependent: :destroy                     # ユーザーが削除されるといいねも削除される
  has_many :liked_study_logs, through: :likes, source: :study_log

  has_many :study_logs, dependent: :destroy                # 学習記録も一緒に削除される
  has_many :study_reminders

  has_many :user_study_badges
  has_many :study_badges, through: :user_study_badges

  has_many :learning_comments, dependent: :destroy         # 学習コメントも一緒に削除される
  has_many :study_genres

  # バリデーション
  validates :name, presence: true                          # 名前は必須
  validates :email, presence: true, uniqueness: { case_sensitive: false }, unless: :from_oauth? # OAuthの場合、emailバリデーションをスキップ

  validates :password, presence: true, on: :create         # 新規作成時はパスワード必須
  validates :password_confirmation, presence: true, on: :create # パスワード確認も必須
  validates :password, confirmation: { message: "が一致しません" }, on: :create, unless: :from_oauth?
  validates :password, confirmation: true

  # GoogleかLINEでのOAuth認証ユーザーかどうかを判定
  def from_oauth?
    from_google_oauth? || from_line_oauth? || from_github_oauth?
  end

  # Googleログインユーザーかどうかを判定
  def from_google_oauth?
    provider == "google_oauth2"
  end

  # LINEログインユーザーかどうかを判定
  def from_line_oauth?
    provider == "line"
  end

  def from_github_oauth?
    provider == "github"
  end

  # 特定のオブジェクトが自分のものかどうかを判定するヘルパー
  def own?(object)
    id == object&.user_id
  end

  # ジャンルを追加できる条件の判定（設定済みが3未満、かつ21日間達成しているものがある場合）
  def can_add_new_genre?
    study_settings.count < 3 && study_settings.any?(&:completed_21_days?)
  end

  # 学習記録の投稿日数ランキングを取得（1日1カウント）
  def self.studied_logs_days_ranking
    StudyLog
      .select(Arel.sql("user_id, COUNT(DISTINCT DATE(date)) AS posted_days_count"))
      .group(:user_id)
      .order(Arel.sql("posted_days_count DESC"))
  end
end
