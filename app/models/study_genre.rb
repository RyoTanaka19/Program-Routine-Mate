class StudyGenre < ApplicationRecord
GENRES = [
  "Ruby",
  "Ruby_on_Rails",
  "SQL",
  "PHP_(プログラミング言語)",
  "Laravel",
  "CakePHP",
  "ITパスポート試験",
  "基本情報技術者試験",
  "応用情報技術者試験",
  "アルゴリズム",
  "Java",
  "Spring_Framework",
  "データベース設計",
  "C言語",
  "C ++",
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
  "Django",
  "HyperText_Markup_Language",
  "Cascading Style Sheets",
  "Go (プログラミング言語)",
  "Swift (プログラミング言語)",
  "Kotlin",
  "Flutter"
]
  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]  # 検索対象として許可するカラムを指定
  end

  belongs_to :user

  has_many :study_logs, dependent: :destroy
  has_many :user_study_genres, dependent: :destroy

  validates :name, presence: true

  validates :name, uniqueness: { scope: :user_id, message: "はすでに登録されています。" }

  validates :name, inclusion: { in: GENRES }

  def study_log_count
    study_logs.count
  end
end
