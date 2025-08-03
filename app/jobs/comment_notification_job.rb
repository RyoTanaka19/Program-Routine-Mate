class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_comment_id)
    study_comment = StudyComment.find(study_comment_id)
    study_log = study_comment.study_log
    commenter = study_comment.user

    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(30)
    message = "#{commenter.name}さんがあなたの学習記録「#{safe_content}」にコメントしました！"

    # 送信先ユーザーのLINE通知も送る
    send_line_notification(message, study_log.user)

    # ブラウザ通知
    broadcast_browser_notification(study_log.user.id, message)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "CommentNotificationJob failed: #{e.message}"
  end

  private

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end

  # 追加: LINE通知を送るメソッド
  def send_line_notification(message, user)
    return if user.uid.blank?

    client = LINE_BOT_API
    client.push_message(user.uid, { type: "text", text: message })
  rescue StandardError => e
    Rails.logger.error("LINE通知送信エラー: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
  end
end
