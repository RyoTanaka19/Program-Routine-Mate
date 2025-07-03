class StudyGenre < ApplicationRecord
GENRES = [
  "Ruby",
  "Ruby_on_Rails",
  "SQL",
  "PHP_(プログラミング言語)",
  "Laravel",
  "CakePHP",
  "Web",
  "ITパスポート試験",
  "基本情報技術者試験",
  "応用情報技術者試験",
  "アルゴリズム",
  "Java",
  "データベース設計",
  "C言語",
  "VBA",
  "Visual_Basic_for_Applications",
  "Git",
  "Docker",
  "Amazon_Web_Services",
  "JavaScript",
  "React",
  "TypeScript",
  "Next.js",
  "Python",
  "HyperText_Markup_Language",
  "Cascading Style Sheets",
  "Go (プログラミング言語)",
  "Swift (プログラミング言語)",
  "Kotlin"
]
  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]  # 検索対象として許可するカラムを指定
  end

  # ===============================
  # アソシエーション
  # ===============================

  # この学習ジャンルは1人のユーザーに属します（所有者の指定）
  belongs_to :user

  # このジャンルに関連付けられた学習ログ（study_logs）を複数持ちます。
  # ジャンルが削除されたときは、関連する学習ログも全て削除されます。
  has_many :study_logs, dependent: :destroy

  # ===============================
  # バリデーション（データの正しさを保証）
  # ===============================

  # name（ジャンル名）は必須項目です。
  validates :name, presence: true

  # 同じユーザーが同じジャンル名を複数登録できないように制限します。
  # 他のユーザーなら同じジャンル名でも登録可能です。
  validates :name, uniqueness: { scope: :user_id, message: "はすでに登録されています。" }

  # 許可されたジャンル名のみ登録できるように制限します。
  validates :name, inclusion: { in: GENRES }

  # ===============================
  # インスタンスメソッド
  # ===============================

  # このジャンルで、21日間連続して学習できているかどうかを確認します。
  # ※ 現在はチェックを無効化しており、常に true を返すようになっています。
  def completed_21_days?
    # 学習ログが1件もなければ、初期状態として true を返す（判定しない）
    return true if study_logs.empty?

    # ↓ 本来の処理（コメントアウト中）:
    # 直近21日間に、学習ログが存在する日が21日分あるかをチェックします。
    # study_logs
    #   .where("created_at >= ?", 21.days.ago.to_date.beginning_of_day)
    #   .group("DATE(created_at)") # 日付単位でまとめる
    #   .count
    #   .keys
    #   .size >= 21

    # 現在は常に学習完了と見なすように設定
    true
  end

  def study_log_count
    study_logs.count
  end
end
