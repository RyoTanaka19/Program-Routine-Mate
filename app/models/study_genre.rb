# app/models/study_genre.rb
class StudyGenre < ApplicationRecord
  GENRES = {
    "Ruby" => "Ruby",
    "Ruby on Rails" => "Ruby_on_Rails",
    "SQL" => "SQL",
    "PHP" => "PHP_(プログラミング言語)",
    "Laravel" => "Laravel",
    "CakePHP" => "CakePHP",
    "ITパスポート試験" => "ITパスポート試験",
    "基本情報技術者試験" => "基本情報技術者試験",
    "応用情報技術者試験" => "応用情報技術者試験",
    "アルゴリズム" => "アルゴリズム",
    "Web技術" => "WEB",
    "Java" => "Java",
    "Spring Framework" => "Spring_Framework",
    "データベース設計" => "データベース設計",
    "C言語" => "C言語",
    "C++" => "C%2B%2B",
    "C#" => "C_sharp",
    "VBA" => "Visual_Basic_for_Applications",
    "Git" => "Git",
    "Docker" => "Docker",
    "AWS" => "Amazon_Web_Services",
    "JavaScript" => "JavaScript",
    "React" => "React",
    "TypeScript" => "TypeScript",
    "Next.js" => "Next.js",
    "Python" => "Python",
    "Django" => "Django",
    "HTML" => "HyperText_Markup_Language",
    "CSS" => "Cascading Style Sheets",
    "Go" => "Go (プログラミング言語)",
    "Swift" => "Swift (プログラミング言語)",
    "Kotlin" => "Kotlin",
    "Flutter" => "Flutter"
  }.freeze

  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end

  belongs_to :user
  has_many :study_logs, dependent: :destroy
  has_many :user_study_genres, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "はすでに登録されています。" }
  validates :name, inclusion: { in: GENRES.values }

  def study_log_count
    study_logs.count
  end

  # 表示名を取得
  def display_name
    StudyGenre::GENRES.key(name) || name
  end
end
