class ReminderNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_reminder_id, time_type)
    study_reminder = StudyReminder.find(study_reminder_id)
    user = study_reminder.user

    # 本人への通知メッセージ
    personal_message = case time_type.to_sym
                       when :start_time
                         "学習が開始されました！開始時間: #{study_reminder.start_time.strftime('%Y-%m-%d %H:%M:%S')}"
                       when :end_time
                         "学習が終了しました！終了時間: #{study_reminder.end_time.strftime('%Y-%m-%d %H:%M:%S')}"
                       else
                         return
                       end

    # 他ユーザー向け通知メッセージ
    broadcast_message = case time_type.to_sym
                        when :start_time
                          "#{user.name}さんが学習を開始しました！"
                        when :end_time
                          "#{user.name}さんが学習を終了しました！"
                        end

    # 本人に通知
    send_line_notification(personal_message, user)
    broadcast_browser_notification(user.id, personal_message)

    # 他ユーザー全員に ActionCable で通知（本人以外）
    broadcast_to_other_users(user.id, broadcast_message)
  end

  private

  def send_line_notification(message, user)
    client = LINE_BOT_API
    client.push_message(user.uid, { type: "text", text: message })
  end

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end

  def broadcast_to_other_users(sender_user_id, message)
    User.where.not(id: sender_user_id).find_each do |user|
      ActionCable.server.broadcast("notification_channel_#{user.id}", { message: message })
      # 必要であれば LINE 通知も送る（※ 通知過多になる可能性がある）
      # send_line_notification(message, user)
    end
  end
end
