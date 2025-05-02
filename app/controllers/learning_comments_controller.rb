class LearningCommentsController < ApplicationController
  # ----------------------------------------
  # フィルター設定
  # ----------------------------------------

  # ユーザーがログインしていない場合、コメントの作成・削除・編集・更新はできないように制限
  # これにより、ログインしていないユーザーがコメントの操作を行えないようにします。
  before_action :authenticate_user!, only: [ :create, :destroy, :edit, :update ]

  # ----------------------------------------
  # コメントの新規作成アクション
  # ----------------------------------------
  def create
    # 対象となる学習記録（StudyLog）をIDから取得
    # コメントが紐づく学習記録を取得します。
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在ログイン中のユーザーに紐づいた新しいコメントインスタンスを作成
    # current_userを使って、コメントがどのユーザーによって投稿されたかを紐づけます。
    @learning_comment = current_user.learning_comments.build(learning_comment_params)

    # コメントに対象の学習記録を紐づける
    # コメントがどの学習記録に関連するかを指定します。
    @learning_comment.study_log = @study_log

    # コメントの保存処理
    if @learning_comment.save
      # 保存に成功した場合：
      # - フォームをリセット（空のフォームを再描画）
      # - 新しいコメントをコメント一覧の先頭に動的に追加します。
      render turbo_stream: [
        turbo_stream.replace(
          "learning_comments-form", # コメントフォームを新しい空のフォームに置き換え
          partial: "learning_comments/form",
          locals: { learning_comment: LearningComment.new, study_log: @study_log }
        ),
        turbo_stream.prepend(
          "learning_comments-list", # コメントリストの先頭に新しいコメントを追加
          partial: "learning_comments/learning_comment",
          locals: { learning_comment: @learning_comment }
        )
      ]
    else
      # バリデーションエラーなどで保存に失敗した場合：
      # - エラー情報を保持した状態でフォームを再表示します。
      render turbo_stream: turbo_stream.replace(
        "learning_comments-form", # エラー付きフォームを再表示
        partial: "learning_comments/form",
        locals: { learning_comment: @learning_comment, study_log: @study_log }
      )
    end
  end

  # ----------------------------------------
  # コメントの削除アクション
  # ----------------------------------------
  def destroy
    # ログインユーザーが作成したコメントのみ取得
    # 自分が作成したコメントのみ削除できるように制限します。
    @learning_comment = current_user.learning_comments.find(params[:id])

    # コメントを削除（destroy! は失敗時に例外を発生させるため、より安全に扱える）
    # コメントをデータベースから削除します。
    @learning_comment.destroy!
  end

  # ----------------------------------------
  # コメントの編集フォーム表示アクション
  # ----------------------------------------
  def edit
    # 指定されたコメントIDからコメントを取得
    # 編集するコメントをデータベースから検索します。
    @learning_comment = LearningComment.find(params[:id])
  end


  # ----------------------------------------
  # コメントの更新アクション
  # ----------------------------------------
  def update
    # 編集対象のコメントを取得
    # 編集対象のコメントをデータベースから検索します。
    @learning_comment = LearningComment.find(params[:id])

    # コメントの内容を更新
    if @learning_comment.update(learning_comment_params)
      # 更新に成功した場合：
      # - 対象のコメント部分だけをTurbo Streamで置き換えて、最新状態を表示します。
      render turbo_stream: turbo_stream.replace(
        "learning_comment_#{@learning_comment.id}",
        partial: "learning_comments/learning_comment",
        locals: { learning_comment: @learning_comment }
      )
    else
      # 更新に失敗した場合：
      # - エラーを表示した編集フォームに差し替えます。
      render turbo_stream: turbo_stream.replace(
        "learning_comment_#{@learning_comment.id}",
        partial: "learning_comments/form",
        locals: { learning_comment: @learning_comment }
      )
    end
  end

  private

  # ----------------------------------------
  # ストロングパラメータ
  # ----------------------------------------
  def learning_comment_params
    # フォームから受け取るパラメータのうち、許可する値を明示的に指定
    # - コメント本文（:text）
    # - 紐づける学習記録のID（:study_log_id）
    # strong parametersを使ってセキュリティ対策を行います。
    params.require(:learning_comment).permit(:text, :study_log_id)
  end
end
