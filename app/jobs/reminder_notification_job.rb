class ReminderNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_reminder_id, time_type)
    # 1. time_typeを安全にシンボル化し、許可された値のみ処理
    time_type_sym = safe_time_type(time_type)
    return unless [ :start_time, :end_time ].include?(time_type_sym)

    study_reminder = StudyReminder.find_by(id: study_reminder_id)
    return unless study_reminder

    user = study_reminder.user
    return unless user

    personal_message = generate_personal_message(study_reminder, time_type_sym)
    broadcast_message = generate_broadcast_message(user, time_type_sym)

    return if personal_message.nil? || broadcast_message.nil?

    send_line_notification(personal_message, user)
    broadcast_notification(user.id, personal_message)
    broadcast_to_other_users(user.id, broadcast_message)
  end

  private

  # 1. time_typeの安全なシンボル変換メソッド
  def safe_time_type(time_type)
    time_type.to_s.downcase.to_sym
  rescue StandardError
    nil
  end

  # 4. メッセージテンプレートの定義を共通化
  PERSONAL_MESSAGES = {
    start_time: "学習が開始されました！開始時間: %{time}",
    end_time:   "学習が終了しました！終了時間: %{time}"
  }.freeze

  BROADCAST_MESSAGES = {
    start_time: "%{name}さんが学習を開始しました！",
    end_time:   "%{name}さんが学習を終了しました！"
  }.freeze

  def generate_personal_message(study_reminder, time_type)
    time = case time_type
    when :start_time then safe_strftime(study_reminder.start_time)
    when :end_time   then safe_strftime(study_reminder.end_time)
    else nil
    end
    return nil unless time

    PERSONAL_MESSAGES[time_type] % { time: time }
  end

  def generate_broadcast_message(user, time_type)
    BROADCAST_MESSAGES[time_type] % { name: user.name }
  end

  # 6. nil安全なstrftime
  def safe_strftime(time)
    time&.strftime("%Y-%m-%d %H:%M:%S")
  end

  def send_line_notification(message, user)
    return if user.uid.blank?

    client = LINE_BOT_API
    client.push_message(user.uid, { type: "text", text: message })
  rescue StandardError => e
    Rails.logger.error("LINE通知送信エラー: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
  end

  def broadcast_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  rescue StandardError => e
    Rails.logger.error("ブラウザ通知送信エラー: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
  end

  # 2. パフォーマンス考慮コメントを追加（大規模ユーザー時は工夫検討）
  def broadcast_to_other_users(sender_user_id, message)
    User.where.not(id: sender_user_id).find_each do |user|
      begin
        ActionCable.server.broadcast("notification_channel_#{user.id}", { message: message })
      rescue StandardError => e
        Rails.logger.error("他ユーザーブラウザ通知送信エラー: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
      end
    end
  end
end
