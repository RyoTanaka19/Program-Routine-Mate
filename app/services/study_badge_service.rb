class StudyBadgeService
  # コンストラクタでユーザーを初期化
  def initialize(user)
    @user = user
  end

  # 初めての学習記録を投稿したユーザーに「初めての学習記録」バッジを付与
  def assign_first_study_log_badge
    # バッジの存在を確認し、ない場合は新しく作成
    badge = StudyBadge.find_or_create_by(
      name: "初めての学習記録",  # バッジの名前
      description: "初めて学習記録を投稿したユーザーに付与されるバッジ",  # バッジの説明
      icon: "icon.png"  # バッジのアイコン（デフォルトアイコンを設定）
    )

    # ユーザーがまだこのバッジを持っていない場合に付与する処理
    unless @user.study_badges.exists?(badge.id)
      # バッジをユーザーに付与（user_study_badgesテーブルに記録）
      @user.user_study_badges.create(study_badge: badge, earned_at: Time.current)
    end
  end
end
