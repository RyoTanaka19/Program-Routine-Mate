class NotifyLineJob < ApplicationJob
  # 使用するキューを指定（非同期ジョブが :default キューで処理される）
  queue_as :default

  # performメソッド：ジョブの実行時に呼ばれるメイン処理
  # 引数に応じて、バッジ通知 または 学習リマインダー通知を実行します
  def perform(study_reminder_id = nil, time_type = nil, badge_id = nil, user_id = nil)
    # 🎖 バッジ獲得通知の処理
    if badge_id.present? && user_id.present?
      # 対象のバッジとユーザーを取得
      badge = StudyBadge.find(badge_id)
      user  = User.find(user_id)

      # 通知メッセージを作成
      message = "🎉 #{user.name}さんが「#{badge.name}」バッジを獲得しました！"

      # LINE通知を送信
      send_line_notification(message, user)

      # ブラウザ通知（ActionCable）を送信
      broadcast_browser_notification(user_id, message)

    # ⏰ 学習リマインダー通知の処理
    elsif study_reminder_id.present? && time_type.present?
      # 対象の学習リマインダーを取得
      study_reminder = StudyReminder.find(study_reminder_id)

      # 指定された時間（開始 or 終了）まで待機
      wait_until_time(study_reminder, time_type)

      # 通知内容を作成
      message = case time_type
      when :start_time
                  "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
      when :end_time
                  "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
      end

      # 通知対象のユーザーを取得
      user = study_reminder.user

      # LINE通知とブラウザ通知を送信
      send_line_notification(message, user)
      broadcast_browser_notification(user.id, message)
    end
  end

  private

  # 📌 指定された時間までスリープして待つメソッド
  def wait_until_time(study_reminder, time_type)
    # 通知対象の時刻（開始 or 終了）を取得
    target_time = time_type == :start_time ? study_reminder.start_time : study_reminder.end_time

    # 現在時刻との差を計算し、その分だけスリープ（時間が過ぎていればスキップ）
    sleep_time = target_time - Time.current
    sleep(sleep_time) if sleep_time > 0
  end

  # 📩 LINE通知を送信する処理
  def send_line_notification(message, user)
    # LINE Messaging API のクライアントを使用
    client = LINE_BOT_API

    # 指定ユーザー（user.uid）にテキストメッセージを送信
    client.push_message(user.uid, { type: "text", text: message })
  end

  # 📢 ActionCable を使ってブラウザに通知を送る処理
  def broadcast_browser_notification(user_id, message)
    # 特定ユーザーの通知チャンネルに対してメッセージをブロードキャスト
    ActionCable.server.broadcast(
      "study_reminder_channel_#{user_id}",
      { message: message }
    )
  end
end
