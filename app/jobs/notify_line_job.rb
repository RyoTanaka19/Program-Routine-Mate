class NotifyLineJob < ApplicationJob
  # ジョブの実行メソッド
  # このジョブは、LINE通知やブラウザ通知を送信する役割を持っています。
  # バッジ獲得の通知や学習リマインダー通知を処理します。
  queue_as :default

  def perform(study_reminder_id = nil, time_type = nil, badge_id = nil, user_id = nil)
    if badge_id.present? && user_id.present?
      # 🎖 バッジ通知の場合
      # バッジ情報を取得する。`badge_id` でバッジを検索
      badge = StudyBadge.find(badge_id)  
      
      # ユーザー情報を取得する。`user_id` でユーザーを検索
      user = User.find(user_id)  

      # 通知メッセージを作成（バッジ獲得のお祝いメッセージ）
      message = "🎉 #{user.name}さんが「#{badge.name}」バッジを獲得しました！"

      # LINE通知を送信するメソッドを呼び出し
      send_line_notification(message)

      # ブラウザ通知を送信するメソッドを呼び出し
      broadcast_browser_notification(user_id, message)

    elsif study_reminder_id.present? && time_type.present?
      # ⏰ 学習時間通知の場合
      # 学習リマインダー情報を取得する。`study_reminder_id` でリマインダーを検索
      study_reminder = StudyReminder.find(study_reminder_id)
      
      # 指定された時間まで待機する処理
      wait_until_time(study_reminder, time_type)

      # 時間タイプに応じてメッセージを作成
      # 学習開始時刻または終了時刻に基づいてメッセージを生成
      message = case time_type
                when :start_time
                  # 学習開始時間の通知メッセージ
                  "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
                when :end_time
                  # 学習終了時間の通知メッセージ
                  "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
                end

      # LINE通知を送信するメソッドを呼び出し
      send_line_notification(message)

      # ブラウザ通知を送信するメソッドを呼び出し
      broadcast_browser_notification(study_reminder.user_id, message)
    end
  end

  private

  # 指定された時間（開始または終了時間）まで待機する処理
  # 学習リマインダーの開始または終了時刻まで待機するためのメソッド
  def wait_until_time(study_reminder, time_type)
    # 開始時間または終了時間を設定
    target_time = time_type == :start_time ? study_reminder.start_time : study_reminder.end_time
    
    # 現在時刻との残り時間を計算
    sleep_time = target_time - Time.current
    
    # 残り時間が正の値の場合、指定された時間まで待機
    sleep(sleep_time) if sleep_time > 0
  end

  # LINEに通知を送信するメソッド
  # LINE_BOT_APIを使って、指定されたメッセージをLINEで送信する
  def send_line_notification(message)
    # LINE_BOT_API を利用して LINE メッセージを送信
    client = LINE_BOT_API
    # メッセージ送信先のユーザーIDは環境変数から取得
    client.push_message(
      ENV["LINE_USER_ID"],  # ユーザーID（LINEの通知を送信する先）
      [{ type: "text", text: message }]  # 送信するメッセージ内容
    )
  end

  # ブラウザのリアルタイム通知を送信するメソッド
  # ActionCable を使用して、指定したユーザーにメッセージをブロードキャスト（リアルタイム通知）
  def broadcast_browser_notification(user_id, message)
    # ActionCableを使って、ユーザー固有のチャンネルにメッセージを送信
    ActionCable.server.broadcast(
      "study_reminder_channel_#{user_id}",  # ユーザー固有のチャンネルにメッセージを送信
      { message: message }  # 送信するメッセージ内容
    )
  end
end
