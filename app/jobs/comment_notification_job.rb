class CommentNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_comment_id)
    study_comment = StudyComment.find_by(id: study_comment_id)
    return Rails.logger.warn "StudyComment not found with id #{study_comment_id}" if study_comment.nil?

    study_log = study_comment.study_log
    commenter = study_comment.user

    # 学習記録の内容をタグを取り除いて、30文字でトリミング
    safe_content = ActionController::Base.helpers.strip_tags(study_log.content).truncate(30, omission: "")

    # i18nを使ってメッセージを生成
    message = I18n.t("comment_notification", commenter_name: commenter.name, content: safe_content)

    # 通知を送信
    broadcast_notification(study_log.user.id, message)
  rescue => e
    Rails.logger.warn "CommentNotificationJob failed: #{e.message}"
    Rails.logger.warn e.backtrace.join("\n")
  end

  private

  # 通知を送信するメソッド
  def broadcast_notification(user_id, message, broadcast_service = ActionCable.server)
    broadcast_service.broadcast("notification_channel_#{user_id}", { message: message })
  end
end
