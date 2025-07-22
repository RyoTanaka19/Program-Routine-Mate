class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_comment_id)
    study_comment = StudyComment.find(study_comment_id)
    study_log = study_comment.study_log
    commenter = study_comment.user

    message = "#{commenter.name}さんがあなたの学習記録「#{study_log.content}」にコメントしました！"

    # LINE通知は削除しました
    broadcast_browser_notification(study_log.user.id, message)
  end

  private

  # send_line_notification メソッド自体も削除しました

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end
end
