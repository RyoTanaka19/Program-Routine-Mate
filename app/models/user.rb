class User < ApplicationRecord
  # Deviseを使用してユーザー認証機能を提供
  # 利用するDeviseのモジュール：
  # :database_authenticatable - メールアドレスとパスワードによる認証を可能にする
  # :registerable - ユーザーが自分でアカウントを新規登録・編集・削除できるようにする
  # :recoverable - パスワードを忘れた際に再設定できる機能を提供（リセットメールの送信など）
  # :rememberable - ブラウザにログイン情報を保存し、次回以降自動でログインできるようにする
  # :omniauthable - Google、LINE、GitHubなどの外部認証サービス（OAuth）を利用したログインを可能にする
  # omniauth_providers - 使用するSNSプロバイダーの一覧を指定（複数指定可）
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[google_oauth2 line ]

  # SNSログインにおいて、同一プロバイダー内でのUIDの重複を防止する
  # UIDは各プロバイダー（Google, LINE, GitHubなど）が提供する一意のユーザー識別子
  # scope: :provider を指定することで、「同じプロバイダー × 同じUID」での重複のみを禁止する
  # 例: GoogleのUID「12345」は1人のユーザーだけに関連付けられる（別のユーザーで登録は不可）
  # ただし、GitHubで同じUID「12345」が使われていても問題ない（別のプロバイダーだから）
  validates :uid, uniqueness: { scope: :provider }

# ユーザーのSNS認証情報をもとに、既存のユーザーを検索するか、新規に作成するクラスメソッド
def self.from_omniauth(auth)
  # SNSプロバイダー（Google, LINEなど）とUID（SNSでの一意の識別子）で既存のユーザーを検索
  # 見つからない場合は、新しいユーザーを作成します。
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    # SNSのプロバイダーがGoogleの場合の特別な処理
    if auth.provider == "google_oauth2"
      # Googleではメールアドレスが提供されるので、それをユーザーのメールとして設定
      user.email = auth.info.email if auth.info.email.present? # メールアドレスがある場合のみ設定
    # SNSのプロバイダーがLINEの場合の特別な処理
    elsif auth.provider == "line"
      # LINEでは、メールアドレスが取得できないことがあるので、
      # 取得できた場合のみメールを設定します。もしメールが無い場合でもスキップします。
      user.email = auth.info.email if auth.info.email.present?
    end

    # パスワードはランダムに生成されたトークンを使い、20文字に設定します。
    # SNS認証の場合、パスワードは通常不要ですが、Deviseの仕様で必要なため仮のパスワードを生成します。
    user.password = Devise.friendly_token[0, 20] # Deviseのランダムトークンを20文字に切り取る
    user.password_confirmation = user.password  # パスワード確認用にも同じ値を設定

    # ユーザーの名前（プロフィール名）をSNSの認証情報から取得して設定
    user.name = auth.info.name  # 名前（または表示名）をSNSから取得して設定

    # ユーザー情報をデータベースに保存します。保存が失敗した場合、例外が発生します。
    user.save!  # ユーザー情報を保存、失敗した場合は例外が発生して処理が中断します
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

  # Google、LINE、GitHubいずれかのOAuth認証を使用してログインしたユーザーかどうかを判定します。
  # いずれかのSNS認証であれば true を返し、そうでなければ false を返します。
  def from_oauth?
    from_google_oauth? || from_line_oauth? || from_github_oauth?
  end

  # Googleアカウントを使ってログインしたユーザーかどうかを判定します。
  # provider カラムが "google_oauth2" の場合に true を返します。
  def from_google_oauth?
    provider == "google_oauth2"
  end

  # LINEアカウントを使ってログインしたユーザーかどうかを判定します。
  # provider カラムが "line" の場合に true を返します。
  def from_line_oauth?
    provider == "line"
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
    # StudyLogテーブルから、ユーザーごとに学習ログが記録された「異なる日付」の数を集計し、
    # 「投稿日数（posted_days_count）」としてカウントする。
    # 同じ日に複数のログがあっても、1日としてカウントするため、DISTINCT DATE(date) を使用。
    # 最終的に、投稿日数が多い順に並べたランキングを返す。
    StudyLog
      .select(Arel.sql("user_id, COUNT(DISTINCT DATE(date)) AS posted_days_count"))
      .group(:user_id)
      .order(Arel.sql("posted_days_count DESC"))
  end
end
