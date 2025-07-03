class NotifyLineJob < ApplicationJob
  queue_as :default

  def perform(study_reminder_id = nil, time_type = nil, badge_id = nil, user_id = nil)
    if badge_id.present? && user_id.present?

      badge = StudyBadge.find(badge_id)
      user  = User.find(user_id)


      message = "🎉 #{user.name}さんが「#{badge.name}」バッジを獲得しました！"


      send_line_notification(message, user)


      broadcast_browser_notification(user_id, message)


    elsif study_reminder_id.present? && time_type.present?

      study_reminder = StudyReminder.find(study_reminder_id)


      wait_until_time(study_reminder, time_type)


      message = case time_type
      when :start_time
                  "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
      when :end_time
                  "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
      end

      user = study_reminder.user

      send_line_notification(message, user)
      broadcast_browser_notification(user.id, message)
    end
  end

  private

  def wait_until_time(study_reminder, time_type)
    target_time = time_type == :start_time ? study_reminder.start_time : study_reminder.end_time

    sleep_time = target_time - Time.current
    sleep(sleep_time) if sleep_time > 0
  end

  def send_line_notification(message, user)
    client = LINE_BOT_API

    client.push_message(user.uid, { type: "text", text: message })
  end

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast(
      "study_reminder_channel_#{user_id}",
      { message: message }
    )
  end
end
