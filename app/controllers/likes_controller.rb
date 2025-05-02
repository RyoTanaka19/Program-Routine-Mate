class LikesController < ApplicationController
  # ================================
  # 学習ログに「いいね」を追加するアクション
  # ================================
  def create
    # 対象の学習ログをIDから取得
    # 送られてきたparams[:study_log_id]から、対象の学習ログを検索します
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在ログイン中のユーザーがその学習ログに対して「いいね」を作成
    # 学習ログに紐づくLikeオブジェクトを作成します。userは現在ログイン中のユーザーです。
    @like = @study_log.likes.build(user: current_user)

    # 「いいね」を保存
    if @like.save
      # 保存に成功した場合、リクエスト形式に応じてレスポンスを返します。
      respond_to do |format|
        # 通常のHTMLリクエストの場合：
        # 学習ログ一覧ページにリダイレクトし、"いいねしました！"という通知を表示します。
        format.html { redirect_to study_logs_path, notice: "いいねしました！" }

        # Turbo Streamリクエストの場合：
        # ページをリロードせずに部分的な更新を行います。
        format.turbo_stream do
          render turbo_stream: [
            # 「いいねボタン」の部分を再描画（例えばハートアイコンが変化する）
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
      # 保存に失敗した場合、学習ログ一覧ページにリダイレクトし、エラーメッセージを表示します。
      redirect_to study_logs_path, alert: "いいねできませんでした。"
    end
  end

  # ================================
  # 学習ログから「いいね」を削除するアクション
  # ================================
  def destroy
    # 対象の学習ログを取得
    # 送られてきたparams[:study_log_id]から、対象の学習ログを検索します
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在のユーザーがつけた「いいね」を検索（1ユーザーにつき1つの「いいね」が前提）
    # すでにその学習ログにユーザーが「いいね」をしている場合、それを検索して取得します。
    @like = @study_log.likes.find_by(user: current_user)

    if @like
      # もし「いいね」が存在する場合は、それを削除します
      @like.destroy

      # 削除後、リクエスト形式に応じてレスポンスを返します
      respond_to do |format|
        # HTMLリクエストの場合：
        # 学習ログ一覧ページにリダイレクトし、"いいねを取り消しました。"という通知を表示します。
        format.html { redirect_to study_logs_path, notice: "いいねを取り消しました。" }

        # Turbo Streamリクエストの場合：
        # ページをリロードせずに部分的な更新を行います。
        format.turbo_stream do
          render turbo_stream: [
            # いいねボタンの再描画（ハートの状態が変更されます）
            turbo_stream.replace(
              "like-button-#{@study_log.id}",
              partial: "study_logs/like_button",
              locals: { study_log: @study_log }
            ),
            # いいね数の更新
            turbo_stream.update(
              "like-count-#{@study_log.id}",
              "<p>いいねの数: #{@study_log.likes.count}</p>"
            )
          ]
        end
      end
    else
      # ユーザーがまだ「いいね」をしていない場合など、いいねが見つからなかった場合
      # 学習ログ一覧ページにリダイレクトし、「いいねが見つかりません」というエラーメッセージを表示します。
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end
end
