class StudyLog < ApplicationRecord
  # 画像アップロード機能（CarrierWave）
  # imageカラムに画像ファイルをアップロードできるように設定
  mount_uploader :image, StudyLogsImageUploader

  # 学習記録は必ず1人のユーザーに属する
  belongs_to :user

  # 学習記録は1つの学習ジャンルに属する（例: Ruby, JavaScriptなど）
  belongs_to :study_genre

  # 学習リマインダーは任意（なくてもOK）
  # リマインダーがある場合、学習時間の自動計算に使われる
  belongs_to :study_reminder, optional: true

  # 投稿後にバッジを付与する（初回投稿など）
  after_create :assign_badges

  # いいね機能との関連付け
  # この学習記録に対するいいねが複数存在する
  has_many :likes, dependent: :destroy

  # この学習記録をいいねしたユーザー一覧を取得できるように設定
  has_many :liked_users, through: :likes, source: :user

  # 学習記録に紐づくコメント機能
  has_many :learning_comments, dependent: :destroy

  # ---------- バリデーション（空でないことのチェック） ----------
  # 「学習内容」は必須
  validates :content, presence: true

  # 「学んだこと」も必須
  validates :text, presence: true

  # 学習した日付も必須
  validates :date, presence: true

  # ---------- Ransack（検索）で許可するカラム ----------
  # Ransackを使ってcontentとstudy_genre_idで検索できるようにする
  def self.ransackable_attributes(auth_object = nil)
    super + [ "content", "study_genre_id " ]
  end

  # 関連モデル（アソシエーション）で検索対象とするもの
  def self.ransackable_associations(auth_object = nil)
    super + [ "study_genre" ]
  end

  # レコード作成前に学習時間を自動計算する
  before_create :calculate_study_duration

  private

  # リマインダーが存在し、開始・終了時間が設定されている場合に、
  # 学習時間（分）を `total` に代入する
  def calculate_study_duration
    return unless study_reminder.present?
    return unless study_reminder.start_time.present? && study_reminder.end_time.present?

    start_time = study_reminder.start_time
    end_time = study_reminder.end_time

    # 秒単位の差分を分単位にして整数で保存
    self.total = ((end_time - start_time) / 60).to_i
  end

  # 初回の学習記録投稿時に、バッジを付与する処理
  def assign_badges
    if user.study_logs.count == 1
      # サービスクラスを使ってバッジ付与を外部化（責務の分離）
      StudyBadgeService.new(user).assign_first_study_log_badge
    end
  end
end
