class LearningCommentsController < ApplicationController
  # ユーザーがログインしていない場合、コメントの作成・編集・更新・削除はできないように制限
  before_action :authenticate_user!, only: [ :create, :destroy, :edit, :update ]

    # コメントの新規作成処理
    def create
      # 現在ログイン中のユーザーに紐づけてコメントを作成
      @learning_comment = current_user.learning_comments.build(learning_comment_params)

      # バリデーションに基づき保存（失敗時の処理は必要に応じて追加）
      @learning_comment.save
    end

  def destroy
    # ログインユーザーが作成したコメントのみ削除可能とする（不正操作の防止）
    @learning_comment = current_user.learning_comments.find(params[:id])

    # コメントを削除（バリデーションなどで失敗することは基本的にないが、明示的に破壊的に削除）
    @learning_comment.destroy!
  end

  # コメント編集画面の表示処理
  def edit
    # 編集対象の学習コメントを取得
    @learning_comment = LearningComment.find(params[:id])
  end

  # コメントの更新処理
  def update
    # 更新対象のコメントを取得
    @learning_comment = LearningComment.find(params[:id])

    # コメント内容を更新（失敗時の処理は必要に応じて追加）
    @learning_comment.update(learning_comment_params)
  end

  private

  # Strong Parameters：許可されたパラメータのみを受け取る
  def learning_comment_params
    # コメントの本文と、関連する学習記録のIDを受け取る
    params.require(:learning_comment).permit(:text).merge(study_log_id: params[:study_log_id])
  end
end
