class LikesController < ApplicationController
  # いいねを作成（追加）するアクション
  def create
    # 対象の学習ログをIDから取得
    @study_log = StudyLog.find(params[:study_log_id])
    # 現在ログイン中のユーザーがその学習ログに対していいねを作成
    @like = @study_log.likes.build(user: current_user)

    # いいねの保存処理
    if @like.save
      # レスポンスの形式（HTML or Turbo）に応じて処理を分ける
      respond_to do |format|
        # 通常のHTMLリクエストの場合、学習ログ一覧へリダイレクトし、メッセージを表示
        format.html { redirect_to study_logs_path, notice: "いいねしました！" }

        # Turbo Stream（部分的に画面更新する仕組み）でのリクエストの場合
        format.turbo_stream do
          render turbo_stream: [
            # 「いいねボタン」を部分的に描画し直す（ハートの表示切り替えなど）
            turbo_stream.replace("like-button-#{@study_log.id}", partial: "study_logs/like_button", locals: { study_log: @study_log }), # 修正: コロンの前後にスペース
            # 「いいね数」の部分も更新する
            turbo_stream.update("like-count-#{@study_log.id}", "<p>いいねの数: #{@study_log.likes.count}</p>")
          ]
        end
      end
    else
      # 保存できなかった場合の処理（バリデーションエラーなど）
      redirect_to study_logs_path, alert: "いいねできませんでした。"
    end
  end

  # いいねを削除（取り消し）するアクション
  def destroy
    # 対象の学習ログを取得
    @study_log = StudyLog.find(params[:study_log_id])
    # 現在のユーザーがつけたいいねを検索（1ユーザー1いいね前提）
    @like = @study_log.likes.find_by(user: current_user)

    if @like
      # いいねが存在する場合は削除する
      @like.destroy
      respond_to do |format|
        # 通常のHTMLリクエストの場合
        format.html { redirect_to study_logs_path, notice: "いいねを取り消しました。" }

        # Turbo Streamでのリクエストの場合（ボタンと数を更新）
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("like-button-#{@study_log.id}", partial: "study_logs/like_button", locals: { study_log: @study_log }), # 修正: コロンの前後にスペース
            turbo_stream.update("like-count-#{@study_log.id}", "<p>いいねの数: #{@study_log.likes.count}</p>")
          ]
        end
      end
    else
      # すでにいいねしていない場合など
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end
end
