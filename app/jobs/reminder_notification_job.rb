class ReminderNotificationJob < ApplicationJob
  queue_as :default

def perform(study_reminder_id, time_type)
  study_reminder = StudyReminder.find(study_reminder_id)



  message = case time_type.to_sym
  when :start_time
              "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
  when :end_time
              "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
  else
              return
  end

  user = study_reminder.user

  send_line_notification(message, user)
  broadcast_browser_notification(user.id, message)
end

  private


  def send_line_notification(message, user)
    client = LINE_BOT_API
    client.push_message(user.uid, { type: "text", text: message })
  end

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end
end
