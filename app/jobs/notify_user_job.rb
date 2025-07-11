class NotifyUserJob < ApplicationJob
  queue_as :default

  def perform(study_reminder_id = nil, time_type = nil, badge_id = nil, user_id = nil, learning_comment_id = nil, study_log_id = nil)
    if badge_id.present? && user_id.present?
      badge = StudyBadge.find(badge_id)
      user = User.find(user_id)
      message = "🎉 #{user.name}さんが「#{badge.name}」バッジを獲得しました！"

      send_line_notification(message, user)
      broadcast_browser_notification(user.id, message)

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

    elsif learning_comment_id.present?
      # コメント通知
      learning_comment = LearningComment.find(learning_comment_id)
      study_log = learning_comment.study_log
      user = learning_comment.user

      message = "#{user.name}さんがあなたの学習記録「#{study_log.content}」にコメントしました！"

      send_line_notification(message, study_log.user)
      broadcast_browser_notification(study_log.user.id, message)

    elsif study_log_id.present? && user_id.present?
      # いいね通知
      study_log = StudyLog.find(study_log_id)
      liker = User.find(user_id)
      owner = study_log.user

      return if liker.id == owner.id  # 自分の投稿にいいねした場合は通知しない

      message = "#{liker.name}さんがあなたの学習記録「#{study_log.content.truncate(20)}」にいいねしました！"

      send_line_notification(message, owner)
      broadcast_browser_notification(owner.id, message)
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
      "notification_channel_#{user_id}",
      { message: message }
    )
  end
end
