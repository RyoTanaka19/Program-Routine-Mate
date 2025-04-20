class StudyBadgeService
  # このクラスはユーザーに学習バッジを付与するサービスクラスです。
  # ユーザーが「初めての学習記録」を達成したときにバッジを付与します。

  def initialize(user)
    # `user` は、このサービスを利用するユーザーオブジェクトです。
    # ユーザーがバッジを取得する対象となります。
    @user = user
  end

  # ユーザーが「初めての学習記録」を投稿したときに呼ばれるメソッドです。
  # このメソッドは、ユーザーが初めて学習記録を投稿したことを確認し、対応するバッジを付与します。
  def assign_first_study_log_badge
    # 「初めての学習記録」バッジを取得または新規作成します。
    # `StudyBadge.find_or_create_by` を使用して、バッジが既に存在しない場合は新規作成します。
    badge = StudyBadge.find_or_create_by(
      name: "初めての学習記録",  # バッジの名前
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ", # バッジの説明
      icon: "icon.png"  # バッジに関連するアイコンの名前（ここでは仮に "icon.png" を使用）
    )

    # ユーザーがまだこのバッジを持っていない場合に処理を行います。
    # `@user.study_badges.exists?(badge.id)` で、ユーザーが既にこのバッジを持っているか確認します。
    unless @user.study_badges.exists?(badge.id)
      # ユーザーにバッジを付与します。
      # `user_study_badges` テーブルに新たなレコードを作成して、バッジの付与を記録します。
      # `earned_at` にはバッジ獲得時の時間（現在時刻）を保存します。
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)

      # バッジ獲得を通知するために、LINE通知をバックグラウンドジョブで送信します。
      # `NotifyLineJob.perform_later` を呼び出して非同期で通知を送信します。
      # 通知内容にはバッジのIDとユーザーのIDを渡しますが、`nil` が渡されている部分は引数が不要であるか、後で追加される可能性があります。
      NotifyLineJob.perform_later(nil, nil, badge.id, @user.id)
    end
  end
end
