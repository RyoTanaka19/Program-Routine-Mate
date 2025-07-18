class ReminderNotificationJob < ApplicationJob
  queue_as :default

def perform(study_reminder_id, time_type)
  time_type_sym = time_type.to_sym  # ここで一度だけシンボル化

  study_reminder = StudyReminder.find_by(id: study_reminder_id)
  return unless study_reminder

  user = study_reminder.user
  return unless user

  personal_message = generate_personal_message(study_reminder, time_type_sym)
  broadcast_message = generate_broadcast_message(user, time_type_sym)

  return if personal_message.nil? || broadcast_message.nil?

  send_line_notification(personal_message, user)
  broadcast_browser_notification(user.id, personal_message)
  broadcast_to_other_users(user.id, broadcast_message)
end

  private

  def generate_personal_message(study_reminder, time_type)
    case time_type.to_sym
    when :start_time
      "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
    when :end_time
      "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
    else
      nil
    end
  end

  def generate_broadcast_message(user, time_type)
    case time_type.to_sym
    when :start_time
      "#{user.name}さんが学習を開始しました！"
    when :end_time
      "#{user.name}さんが学習を終了しました！"
    else
      nil
    end
  end

  def send_line_notification(message, user)
    client = LINE_BOT_API
    client.push_message(user.uid, { type: "text", text: message })
  rescue StandardError => e
    Rails.logger.error("LINE通知送信エラー: #{e.message}")
  end

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end

  def broadcast_to_other_users(sender_user_id, message)
    User.where.not(id: sender_user_id).find_each do |user|
      ActionCable.server.broadcast("notification_channel_#{user.id}", { message: message })
      # send_line_notification(message, user)  # 通知過多に注意
    end
  end
end
