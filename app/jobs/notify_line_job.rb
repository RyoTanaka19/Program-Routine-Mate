require "line/bot"

# 学習リマインダーの通知をLINEおよびブラウザに送信する非同期ジョブ
class NotifyLineJob < ApplicationJob
  queue_as :default  # ジョブのキューを"default"に設定（Sidekiqなどで使用）

  # ジョブの実行処理（study_reminder_id: 対象リマインダーのID, time_type: :start_timeまたは:end_time）
  def perform(study_reminder_id, time_type)
    # 対象の学習リマインダーをデータベースから取得
    study_reminder = StudyReminder.find(study_reminder_id)

    # 通知対象の時間（開始または終了）になるまで待機
    wait_until_time(study_reminder, time_type)

    # 通知メッセージを作成（開始か終了かで内容を分岐）
    message = case time_type
    when :start_time
                "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
    when :end_time
                "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
    end

    # LINE通知を送信
    send_line_notification(message)

    # ブラウザ通知（ActionCable経由）を送信
    broadcast_browser_notification(study_reminder.user_id, message)
  end

  private

  # 指定された時刻（開始または終了）になるまで待機する処理
  def wait_until_time(study_reminder, time_type)
    # 通知対象の時刻を取得
    target_time = case time_type
    when :start_time
                    study_reminder.start_time
    when :end_time
                    study_reminder.end_time
    end

    # 現在時刻との差を計算し、まだその時刻でなければsleepする
    sleep_time = target_time - Time.current
    sleep(sleep_time) if sleep_time > 0
  end

  # LINEにテキスト通知を送る処理
  def send_line_notification(message)
    client = LINE_BOT_API  # LINE Botクライアント（初期化済みの定数として利用）
    response = client.push_message(
      ENV["LINE_USER_ID"], # 環境変数から送信先ユーザーIDを取得
      [ { type: "text", text: message } ] # 送信するメッセージ（配列）
    )
    # エラーハンドリングなどを追加することも検討できます
  end

  # ActionCableを使ってブラウザにリアルタイム通知を送信する処理
  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast(
      "study_reminder_channel_#{user_id}", # ユーザーごとの通知用チャンネル
      { message: message }                 # クライアントに渡すデータ（メッセージ）
    )
  end
end
