class LearningCommentsController < ApplicationController
  # ユーザーがログインしていない場合、コメントの作成・編集・更新・削除を制限
  before_action :authenticate_user!, only: [ :create, :destroy, :edit, :update ]

  # ----------------------------------------
  # コメントの新規作成処理
  # ----------------------------------------
  def create
    # 対象の学習記録（StudyLog）を取得
    @study_log = StudyLog.find(params[:study_log_id])

    # 現在ログイン中のユーザーに紐づくコメントインスタンスを作成
    @learning_comment = current_user.learning_comments.build(learning_comment_params)

    # コメントと学習記録を関連付ける
    @learning_comment.study_log = @study_log

    if @learning_comment.save
      # コメントが正常に保存された場合、Turbo Streamで動的にフォームをリセットし、
      # コメントリストの先頭に新しいコメントを追加する
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
      # バリデーションエラーが発生した場合、エラー付きのフォームを再描画
      render turbo_stream: turbo_stream.replace(
        "learning_comments-form",
        partial: "learning_comments/form",
        locals: { learning_comment: @learning_comment, study_log: @study_log }
      )
    end
  end

  # ----------------------------------------
  # コメントの削除処理
  # ----------------------------------------
  def destroy
    # 自分が作成したコメントのみ削除可能（不正なアクセスを防止）
    @learning_comment = current_user.learning_comments.find(params[:id])

    # コメントを削除（destroy!は例外を発生させるので安全に扱える）
    @learning_comment.destroy!
  end

  # ----------------------------------------
  # コメント編集フォームの表示処理
  # ----------------------------------------
  def edit
    # 編集対象のコメントを取得
    @learning_comment = LearningComment.find(params[:id])
  end

  # ----------------------------------------
  # コメントの更新処理
  # ----------------------------------------
  def update
    @learning_comment = LearningComment.find(params[:id])

    if @learning_comment.update(learning_comment_params)
      # コメントが更新された場合、対象のコメント部分だけをTurbo Streamで置き換える
      render turbo_stream: turbo_stream.replace(
        "learning_comment_#{@learning_comment.id}",
        partial: "learning_comments/learning_comment",
        locals: { learning_comment: @learning_comment }
      )
    else
      # 更新に失敗した場合、エラー付きの編集フォームを表示
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
  # コメント作成・更新時に許可するパラメータを定義
  # ----------------------------------------
  def learning_comment_params
    # コメントの本文と、それが紐づく学習記録IDのみを許可
    params.require(:learning_comment).permit(:text, :study_log_id)
  end
end
