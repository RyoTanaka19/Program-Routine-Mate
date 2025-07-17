class LearningCommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy, :edit, :update ]

def create
  @study_log = StudyLog.find(params[:study_log_id])
  @learning_comment = current_user.learning_comments.build(learning_comment_params)
  @learning_comment.study_log = @study_log

  if @learning_comment.save
    # コメントが保存できたらフラッシュメッセージを表示
    flash[:notice] = "コメントを投稿しました"

    if @learning_comment.study_log.user != current_user
      CommentNotificationJob.perform_later(@learning_comment.id)
    end

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
      ),
      turbo_stream.replace(
        "flash_messages",
        partial: "shared/flash_messages" # フラッシュメッセージを更新
      )
    ]
  else
    render turbo_stream: turbo_stream.replace(
      "learning_comments-form",
      partial: "learning_comments/form",
      locals: { learning_comment: @learning_comment, study_log: @study_log }
    )
  end
end



def destroy
  @learning_comment = current_user.learning_comments.find(params[:id])

  if @learning_comment.destroy
    flash[:notice] = "コメントを削除しました"

    render turbo_stream: [
      turbo_stream.remove("learning_comment_#{@learning_comment.id}"),
      turbo_stream.replace(
        "flash_messages",
        partial: "shared/flash_messages" # フラッシュメッセージを更新
      )
    ]
  else
    flash[:alert] = "コメントの削除に失敗しました"

    render turbo_stream: turbo_stream.replace(
      "flash_messages",
      partial: "shared/flash_messages" # フラッシュメッセージを更新
    )
  end
end

  def edit
    @learning_comment = LearningComment.find(params[:id])
  end

 def update
  @learning_comment = LearningComment.find(params[:id])

  if @learning_comment.update(learning_comment_params)
    flash[:notice] = "コメントを編集しました"

    render turbo_stream: [
      turbo_stream.replace(
        "learning_comment_#{@learning_comment.id}",
        partial: "learning_comments/learning_comment",
        locals: { learning_comment: @learning_comment }
      ),
      turbo_stream.replace(
        "flash_messages",
        partial: "shared/flash_messages" # フラッシュメッセージを更新
      )
    ]
  else
    render turbo_stream: turbo_stream.replace(
      "learning_comment_#{@learning_comment.id}",
      partial: "learning_comments/form",
      locals: { learning_comment: @learning_comment }
    )
  end
end

  private

  def learning_comment_params
    params.require(:learning_comment).permit(:text, :study_log_id)
  end
end
