class LikeNotificationJob < ApplicationJob
  queue_as :default

  def perform(study_log_id, liker_user_id)
    study_log = StudyLog.find(study_log_id)
    liker = User.find(liker_user_id)
    owner = study_log.user

    return if liker.id == owner.id  # 自分の投稿にいいねした場合は通知しない

    message = "#{liker.name}さんがあなたの学習記録「#{study_log.content.truncate(20)}」にいいねしました！"

    # LINE通知は削除しました
    broadcast_browser_notification(owner.id, message)
  end

  private

  # send_line_notification メソッド自体も削除しました

  def broadcast_browser_notification(user_id, message)
    ActionCable.server.broadcast("notification_channel_#{user_id}", { message: message })
  end
end
