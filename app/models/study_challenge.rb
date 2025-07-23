class StudyChallenge < ApplicationRecord
  has_many :study_answers, dependent: :destroy
  belongs_to :study_log

  # 問題文から「正解:」で始まる行をすべて削除し、
  # 前後の空白も取り除いた文字列を返すメソッド
  def question_text
    user_response.lines.reject { |line| line.match?(/^正解:/i) }.join.strip
  end

  # 選択肢のハッシュ（現状は固定、将来的にDB等で管理可能）
  def choices
    {
      "A" => "1つ目の選択肢の説明",
      "B" => "2つ目の選択肢の説明",
      "C" => "3つ目の選択肢の説明",
      "D" => "4つ目の選択肢の説明"
    }
  end
end
