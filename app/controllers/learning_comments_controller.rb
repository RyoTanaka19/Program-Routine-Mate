class LearningCommentsController < ApplicationController
  # ----------------------------------------
  # フィルター設定
  # ----------------------------------------

  # ユーザーがログインしていない場合、コメントの作成・削除・編集・更新はできないように制限
  before_action :authenticate_user!, only: [ :create, :destroy, :edit, :update ]

  # ----------------------------------------
  # コメントの新規作成アクション
  # ----------------------------------------
  def create
    # 対象となる学習記録（StudyLog）をIDから取得
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在ログイン中のユーザーに紐づいた新しいコメントインスタンスを作成
    @learning_comment = current_user.learning_comments.build(learning_comment_params)

    # コメントに対象の学習記録を紐づける
    @learning_comment.study_log = @study_log

    # コメントの保存処理
    if @learning_comment.save
      # 保存に成功した場合：
      # - フォームをリセット（空のフォームを再描画）
      # - 新しいコメントをコメント一覧の先頭に動的に追加
      render turbo_stream: [
        turbo_stream.replace(
          "learning_comments-form",
          partial: "learning_comments/form",
          locals: { learning_comment: LearningComment.new, study_log: @study_log }
        ),
        turbo_stream.prepend(
          "learning_comments-list",
          partial: "learning_comments/learning_comment",
          locals: { learning_comment: @learning_comment }
        )
      ]
    else
      # バリデーションエラーなどで保存に失敗した場合：
      # - エラー情報を保持した状態でフォームを再表示
      render turbo_stream: turbo_stream.replace(
        "learning_comments-form",
        partial: "learning_comments/form",
        locals: { learning_comment: @learning_comment, study_log: @study_log }
      )
    end
  end

  # ----------------------------------------
  # コメントの削除アクション
  # ----------------------------------------
  def destroy
    # ログインユーザーが作成したコメントのみ取得（他人のコメントを削除できないよう制限）
    @learning_comment = current_user.learning_comments.find(params[:id])

    # コメントを削除（destroy! は失敗時に例外を発生させるため、より安全に扱える）
    @learning_comment.destroy!
  end

  # ----------------------------------------
  # コメントの編集フォーム表示アクション
  # ----------------------------------------
  def edit
    # 指定されたコメントIDからコメントを取得
    @learning_comment = LearningComment.find(params[:id])
  end

  # ----------------------------------------
  # コメントの更新アクション
  # ----------------------------------------
  def update
    # 編集対象のコメントを取得
    @learning_comment = LearningComment.find(params[:id])

    # コメントの内容を更新
    if @learning_comment.update(learning_comment_params)
      # 更新に成功した場合：
      # - 対象のコメント部分だけをTurbo Streamで置き換えて、最新状態を表示
      render turbo_stream: turbo_stream.replace(
        "learning_comment_#{@learning_comment.id}",
        partial: "learning_comments/learning_comment",
        locals: { learning_comment: @learning_comment }
      )
    else
      # 更新に失敗した場合：
      # - エラーを表示した編集フォームに差し替え
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
    params.require(:learning_comment).permit(:text, :study_log_id)
  end
end
