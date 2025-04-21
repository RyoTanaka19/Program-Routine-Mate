class StudyBadgeService
  # このクラスは、ユーザーが特定の条件（例: 「初めての学習記録」）を達成したときに
  # 対応するバッジを付与するサービスクラスです。

  def initialize(user)
    # `user` は、このサービスを利用する対象のユーザーオブジェクトです。
    # サービスを呼び出す際に渡されたユーザーを、このクラス内で使用できるようにインスタンス変数に格納します。
    @user = user
  end

  # ユーザーが「初めての学習記録」を投稿したときに呼ばれるメソッドです。
  # このメソッドは、ユーザーが初めて学習記録を投稿したことを確認し、
  # それに対応するバッジ（「初めての学習記録」）を付与します。
  def assign_first_study_log_badge
    # 「初めての学習記録」バッジを取得または新規作成します。
    # `StudyBadge.find_or_create_by` メソッドを使用して、既存のバッジがあればそれを取得し、
    # なければ新たに作成します。
    # `find_or_create_by` は、指定された条件に一致するレコードが存在しない場合に、新しいレコードを作成します。
    badge = StudyBadge.find_or_create_by(
      name: "初めての学習記録",  # バッジの名前（このバッジは初めての学習記録に対して付与される）
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ", # バッジの説明
      icon: "icon.png"  # バッジに関連付けられたアイコンの名前（ここでは仮に "icon.png" を使用）
    )

    # ユーザーがまだ「初めての学習記録」バッジを持っていない場合に処理を行います。
    # `@user.study_badges.exists?(badge.id)` で、ユーザーがこのバッジを既に持っているかを確認します。
    # もし持っていなければ、次のステップでバッジを付与します。
    unless @user.study_badges.exists?(badge.id)
      # ユーザーにバッジを付与するためには、`user_study_badges` テーブルに新しいレコードを作成します。
      # これにより、ユーザーとバッジの関連付けが行われ、バッジが付与されます。
      # `earned_at` には、バッジを獲得した日時（ここでは現在の時刻）を保存します。
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)

      # バッジ獲得の通知をLINEに送信するためのバックグラウンドジョブを実行します。
      # `NotifyLineJob.perform_later` は非同期でジョブを実行し、LINE通知を送信します。
      # 通知には、バッジのIDとユーザーのIDを渡して、どのユーザーがどのバッジを獲得したのかを通知します。
      # 引数として `nil` が渡されている部分は、後で追加する予定か、現在は引数が不要な可能性があります。
      NotifyLineJob.perform_later(nil, nil, badge.id, @user.id)
    end
  end
end
