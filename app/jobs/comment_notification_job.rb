class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(learning_comment_id)
    learning_comment = LearningComment.find(learning_comment_id)
    study_log = learning_comment.study_log
    commenter = learning_comment.user

    message = "#{commenter.name}さんがあなたの学習記録「#{study_log.content}」にコメントしました！"

    send_line_notification(message, study_log.user)
    broadcast_browser_notification(study_log.user.id, message)
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
