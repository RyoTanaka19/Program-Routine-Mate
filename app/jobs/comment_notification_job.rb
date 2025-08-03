class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_comment_id)
    study_comment = StudyComment.find(study_comment_id)
    study_log = study_comment.study_log
    commenter = study_comment.user

    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(30)
    message = "#{commenter.name}さんがあなたの学習記録「#{safe_content}」にコメントしました！"

    broadcast_browser_notification(study_log.user.id, message)
    send_line_notification(study_log.user, message)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "CommentNotificationJob failed: #{e.message}"
  end

  private

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end

  # LINE通知を送信するメソッド
  def send_line_notification(user, message)
    return if user.uid.blank?  # ユーザーのLINE IDが無ければ通知しない

    client = LINE_BOT_API  # LINE APIのクライアントインスタンス
    begin
      client.push_message(user.uid, { type: "text", text: message })  # LINE通知送信
    rescue StandardError => e
      Rails.logger.error("LINE通知送信エラー: #{e.class} #{e.message}\n#{e.backtrace.join("\n")}")
    end
  end
end
