class StudyReminderChannel < ApplicationCable::Channel
  # ユーザーがこのチャンネルにサブスクライブ（接続）したときに呼び出されるメソッド
  def subscribed
    # ユーザーがサブスクライブした際に、ユーザー固有のチャンネルをストリーミング
    # ユーザーのIDを使って、個別のチャンネル名を作成
    stream_from "study_reminder_channel_#{current_user.id}"
  end

  # ユーザーがこのチャンネルからアン・サブスクライブ（切断）したときに呼び出されるメソッド
  def unsubscribed
    # ユーザーが切断した際のクリーンアップ処理をここに記述
    # 現状では特にクリーンアップ処理はありませんが、必要に応じてリソースの解放等を行います。
  end

  # 通知メッセージを送信するメソッド
  # `data` パラメータには通知に関する情報が含まれていると仮定しています。
  def send_notification(data)
    # ブロードキャストを使って、指定したユーザーに通知メッセージを送信
    # `current_user` を使って現在サブスクライブしているユーザーに対して通知を送る
    # `message` というキーで通知メッセージを送信
    StudyReminderChannel.broadcast_to(current_user, message: data["message"])
  end
end
