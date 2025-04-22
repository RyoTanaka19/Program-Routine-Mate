class LikesController < ApplicationController
  # ================================
  # 学習ログに「いいね」を追加するアクション
  # ================================
  def create
    # 対象の学習ログをIDから取得
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在ログイン中のユーザーがその学習ログに対していいねを作成
    @like = @study_log.likes.build(user: current_user)

    # いいねを保存
    if @like.save
      # リクエスト形式に応じて適切なレスポンスを返す
      respond_to do |format|
        # 通常のHTMLリクエスト時：学習ログ一覧ページへリダイレクトし、通知を表示
        format.html { redirect_to study_logs_path, notice: "いいねしました！" }

        # Turbo Streamリクエスト時：部分的な画面更新を実行
        format.turbo_stream do
          render turbo_stream: [
            # 「いいねボタン」の部分を再描画（ハートの切り替えなど）
            turbo_stream.replace(
              "like-button-#{@study_log.id}",
              partial: "study_logs/like_button",
              locals: { study_log: @study_log }
            ),
            # 「いいね数」の表示を更新
            turbo_stream.update(
              "like-count-#{@study_log.id}",
              "<p>いいねの数: #{@study_log.likes.count}</p>"
            )
          ]
        end
      end
    else
      # 保存に失敗した場合：一覧ページへリダイレクトし、エラーメッセージを表示
      redirect_to study_logs_path, alert: "いいねできませんでした。"
    end
  end

  # ================================
  # 学習ログから「いいね」を削除するアクション
  # ================================
  def destroy
    # 対象の学習ログを取得
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在のユーザーがつけた「いいね」を検索（1ユーザーにつき1つのいいねが前提）
    @like = @study_log.likes.find_by(user: current_user)

    if @like
      # いいねが存在する場合は削除
      @like.destroy

      respond_to do |format|
        # HTMLリクエスト時：一覧ページへ戻り、通知を表示
        format.html { redirect_to study_logs_path, notice: "いいねを取り消しました。" }

        # Turbo Streamリクエスト時：対象部分のみ更新
        format.turbo_stream do
          render turbo_stream: [
            # いいねボタンを再描画（ハートの状態を変更）
            turbo_stream.replace(
              "like-button-#{@study_log.id}",
              partial: "study_logs/like_button",
              locals: { study_log: @study_log }
            ),
            # いいね数の表示を更新
            turbo_stream.update(
              "like-count-#{@study_log.id}",
              "<p>いいねの数: #{@study_log.likes.count}</p>"
            )
          ]
        end
      end
    else
      # ユーザーがまだいいねしていなかった場合など
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end
end
