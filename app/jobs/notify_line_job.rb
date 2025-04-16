require "line/bot"

class NotifyLineJob < ApplicationJob
  queue_as :default

  def perform(study_reminder_id, time_type)
    study_reminder = StudyReminder.find(study_reminder_id)

    # 開始時間や終了時間に達するまで待機
    wait_until_time(study_reminder, time_type)

    # 通知の内容を作成
    message = case time_type
    when :start_time
                "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
    when :end_time
                "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
    end

    # LINE通知を送る
    send_line_notification(message)

    # ブラウザ通知を送る（ユーザーID取得が必要）
    broadcast_browser_notification(study_reminder.user_id, message)
  end

  private

  def wait_until_time(study_reminder, time_type)
    target_time = case time_type
    when :start_time
                    study_reminder.start_time
    when :end_time
                    study_reminder.end_time
    end

    sleep_time = target_time - Time.current
    sleep(sleep_time) if sleep_time > 0
  end

  def send_line_notification(message)
    client = LINE_BOT_API
    response = client.push_message(ENV["LINE_USER_ID"], [ { type: "text", text: message } ])
  end

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast(
      "study_reminder_channel_#{user_id}",
      { message: message }
    )
  end
end
