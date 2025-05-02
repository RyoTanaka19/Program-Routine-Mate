class NotifyLineJob < ApplicationJob
  # このジョブは、バッジ獲得時や学習リマインダーに関する
  # 通知（LINE通知・ブラウザ通知）を非同期で送信する役割を担います。
  queue_as :default  # ジョブキューの種類を指定（デフォルトキューを使用）

  def perform(study_reminder_id = nil, time_type = nil, badge_id = nil, user_id = nil)
    # 🎖 バッジ獲得通知の処理
    if badge_id.present? && user_id.present?
      # 指定されたバッジとユーザー情報をデータベースから取得
      badge = StudyBadge.find(badge_id)
      user  = User.find(user_id)

      # 獲得メッセージを生成（例：「〇〇さんが△△バッジを獲得しました！」）
      message = "🎉 #{user.name}さんが「#{badge.name}」バッジを獲得しました！"

      # LINEとブラウザに通知を送信
      send_line_notification(message)
      broadcast_browser_notification(user_id, message)

    # ⏰ 学習リマインダー通知の処理
    elsif study_reminder_id.present? && time_type.present?
      # 指定されたリマインダー情報をデータベースから取得
      study_reminder = StudyReminder.find(study_reminder_id)

      # 通知対象の時間（開始 or 終了）まで待機
      wait_until_time(study_reminder, time_type)

      # 通知メッセージを時間種別に応じて作成
      message = case time_type
      when :start_time
                  "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
      when :end_time
                  "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
      end

      # LINEとブラウザに通知を送信
      send_line_notification(message)
      broadcast_browser_notification(study_reminder.user_id, message)
    end
  end

  private

  # 指定時間（開始 or 終了）まで一時停止（秒単位で sleep）
  def wait_until_time(study_reminder, time_type)
    # 通知対象の時間を設定
    target_time = time_type == :start_time ? study_reminder.start_time : study_reminder.end_time

    # 現在時刻との差を計算（正の値なら sleep）
    sleep_time = target_time - Time.current
    sleep(sleep_time) if sleep_time > 0
  end

  # LINE通知を送信する（LINE Messaging API を使用）
  def send_line_notification(message)
    client = LINE_BOT_API  # LINEクライアントを取得（外部定義済み）
    client.push_message(
      ENV["LINE_USER_ID"],              # 通知先ユーザー（開発中は固定の管理者など）
      [ { type: "text", text: message } ]  # 送信するテキストメッセージ
    )
  end

  # ブラウザ通知を送信する（ActionCableでリアルタイムに通知）
  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast(
      "study_reminder_channel_#{user_id}",  # ユーザー専用の通知チャネル
      { message: message }                  # 送信するメッセージデータ
    )
  end
end
