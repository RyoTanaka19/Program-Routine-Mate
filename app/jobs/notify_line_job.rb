require 'line/bot'
class NotifyLineJob < ApplicationJob
  queue_as :default

  def perform(studying_session_id, time_type)
    studying_session = StudyingSession.find(studying_session_id)

    # 開始時間や終了時間に達するまで待機
    wait_until_time(studying_session, time_type)

    # 通知の内容を作成
    message = case time_type
              when :start_time
                "学習が開始されました！開始時間: #{studying_session.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
              when :end_time
                "学習が終了しました！終了時間: #{studying_session.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
              end

    # LINE通知を送る
    send_line_notification(message)
  end

  private

  def wait_until_time(studying_session, time_type)
    # 開始時間または終了時間まで待機
    target_time = case time_type
                  when :start_time
                    studying_session.start_time
                  when :end_time
                    studying_session.end_time
                  end

    # 現在の時刻がターゲット時間より前であれば待機
    sleep_time = target_time - Time.current
    sleep(sleep_time) if sleep_time > 0
  end

  def send_line_notification(message)
    client = LINE_BOT_API

    response = client.push_message(ENV["LINE_USER_ID"], [{ type: 'text', text: message }])
  end
end
