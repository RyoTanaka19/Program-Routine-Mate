class StudyReminder < ApplicationRecord
  # 📎【アソシエーション】
  # 各 StudyReminder は、必ず1人のユーザーに紐づいています。
  # つまり「誰のリマインダーなのか」がわかるようになっています。
  # この設定により、user.study_reminders や reminder.user のような参照が可能になります。
  belongs_to :user

  # 📅【カレンダー表示用メソッド】
  # このリマインダーを「カレンダーに表示するためのデータ形式」に変換して返します。
  # JSON形式に近いハッシュで、フロントエンド（JavaScriptなど）から使いやすくなっています。
  def as_calendar_event
    {
      title: "学習時間",                    # カレンダーに表示されるタイトル（ここでは固定で「学習時間」）
      start: start_time.iso8601,          # イベント開始時刻を ISO 8601 形式に変換（例：2025-04-23T10:00:00+09:00）
      end: end_time.iso8601               # イベント終了時刻を同じ形式で
    }
  end

  # ✅【バリデーション（入力チェック）】
  # start_time と end_time が空でないことをチェックします。
  # ユーザーがリマインダーを作成・更新するときに、これらが未入力だと保存できません。
  validates :start_time, presence: true   # 開始時刻が必須
  validates :end_time, presence: true     # 終了時刻も必須

  # 💡（追加のバリデーションを入れるならここに書けます）
  # 例えば「終了時刻は開始時刻より後であること」をチェックするカスタムバリデーションなど。
end
