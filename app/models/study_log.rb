class StudyLog < ApplicationRecord
  # 画像アップロード機能（CarrierWave）
  # `image` カラムにアップロードされた画像を保存するために CarrierWave を使用します。
  # StudyLogsImageUploader は、画像のアップロード処理を管理するクラスです。
  mount_uploader :image, StudyLogsImageUploader

  # 学習記録は必ず1人のユーザーに属する
  # `StudyLog` は1人のユーザー（`User` モデル）に関連付けられています。
  # 1つの学習記録は必ず1人のユーザーに紐づけられることを意味します。
  belongs_to :user

  # 学習記録は1つの学習ジャンルに属する（例: Ruby, JavaScript など）
  # `StudyLog` は1つの学習ジャンル（`StudyGenre` モデル）に関連付けられています。
  belongs_to :study_genre

  # 学習リマインダーは任意（なくてもOK）
  # `study_reminder` が設定されている場合、その時間を基に学習時間の計算を行います。
  # 例えば、学習リマインダーに設定された開始時間と終了時間を利用して学習時間を算出します。
  belongs_to :study_reminder, optional: true

  # 投稿後にバッジを付与する（初回投稿など）
  # `after_create` コールバックを使い、学習記録が作成された後にバッジを付与するメソッド `assign_badges` を呼び出します。
  after_create :assign_badges

  # いいね機能との関連付け
  # この学習記録に対して複数のユーザーが「いいね」をつけることができます。
  # `dependent: :destroy` は、学習記録が削除されると関連する「いいね」も一緒に削除されることを意味します。
  has_many :likes, dependent: :destroy

  # この学習記録を「いいね」したユーザー一覧を取得できるように設定
  # `liked_users` というメソッドを使って、いいねしたユーザーの情報を簡単に取得できます。
  has_many :liked_users, through: :likes, source: :user

  # 学習記録に紐づくコメント機能
  # 学習記録に対してコメントを複数持つことができます。
  # `dependent: :destroy` は、学習記録が削除されるとその関連するコメントも削除されることを意味します。
  has_many :learning_comments, dependent: :destroy

  # ---------- バリデーション（空でないことのチェック） ----------
  # 学習内容は必須
  # `content` カラムは空では保存できません。必ず何らかの内容が入力されている必要があります。
  validates :content, presence: true

  # 学んだことも必須
  # `text` カラムも空では保存できません。学んだことが必ず入力されている必要があります。
  validates :text, presence: true

  # 学習した日付も必須
  # `date` カラムも必須です。学習した日付は必ず指定されなければなりません。
  validates :date, presence: true

# ---------- Ransack（検索）で許可するカラム ----------
# `ransack` を使って検索を行う際、検索可能なカラムを指定します。
# ここでは、`content` と `study_genre_id` というカラムを検索対象として追加しています。
#
# `ransackable_attributes`メソッドは、検索フォームで検索できるカラムを制限するために使用します。
# `super`を呼び出すことで、親クラスで定義されたデフォルトの属性に加えて、`content` と `study_genre_id` を検索対象に追加しています。

def self.ransackable_attributes(auth_object = nil)
  super + [ "content", "study_genre_id" ]  # 検索対象に `content` と `study_genre_id` を追加
end

# ---------- 関連モデル（アソシエーション）で検索対象とするもの ----------
# `ransack` では、関連付けられたモデル（ここでは `study_genre`）に対しても検索を行うことができます。
# `ransackable_associations`メソッドで関連モデルを検索対象に追加することができます。
#
# `super`を呼び出すことで、親クラスで定義されたデフォルトの関連モデルに加えて、`study_genre` を検索対象として追加しています。
#
# これにより、`study_genre`関連の属性を使った検索が可能になります。

def self.ransackable_associations(auth_object = nil)
  super + [ "study_genre" ]  # `study_genre` を検索対象の関連モデルとして追加
end

  before_create :calculate_study_duration

  private

  # リマインダーが存在し、開始・終了時間が設定されている場合に学習時間を計算する
  # 学習リマインダーが設定されており、開始時間と終了時間が正しく設定されている場合のみ計算します。
  # 現在の時間がリマインダーの期間内にあるかをチェックし、その後、経過した時間（分）を計算します。
  def calculate_study_duration
    # 学習リマインダーが存在しない場合は処理をスキップ
    return unless study_reminder.present?
  
    # リマインダーの開始時間・終了時間が設定されていない場合は処理をスキップ
    return unless study_reminder.start_time.present? && study_reminder.end_time.present?
  
    start_time = study_reminder.start_time
    end_time = study_reminder.end_time
    current_time = Time.current
  
    # 終了時刻まで含めて、範囲外かチェック
    unless current_time >= start_time && current_time <= end_time
      self.total = nil # 現在時刻がリマインダーの期間外の場合、学習時間を保存しない
      return
    end
  
    # 実際に経過した時間（秒）を計算
    elapsed_seconds = (current_time - start_time).to_i
  
    # 経過時間が1秒未満なら記録しない（誤差対策）
    self.total = elapsed_seconds > 0 ? elapsed_seconds : nil
  end

  # 初回投稿時にバッジを付与する
  # ユーザーが初めて学習記録を投稿した場合、初回投稿バッジを付与します。
  # `StudyBadgeService` サービスクラスを使用してバッジ付与の処理を外部化しています。
  def assign_badges
    # ユーザーの学習記録が1つだけの場合（初回投稿）のみバッジを付与
    if user.study_logs.count == 1
      # サービスクラスを使ってバッジ付与を外部化（責務の分離）
      StudyBadgeService.new(user).assign_first_study_log_badge
    end
  end
end
