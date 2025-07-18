class LearningCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_learning_comment, only: [ :edit, :update, :destroy ]

  def create
    @study_log = StudyLog.find(params[:study_log_id])
    @learning_comment = current_user.learning_comments.build(learning_comment_params)
    @learning_comment.study_log = @study_log

    if @learning_comment.save
      flash[:notice] = "コメントを投稿しました"
      CommentNotificationJob.perform_later(@learning_comment.id) if @learning_comment.study_log.user != current_user

      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to @study_log, notice: "コメントを投稿しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error }
        format.html { redirect_to @study_log, alert: "コメントの投稿に失敗しました" }
      end
    end
  end

  def destroy
    if @learning_comment.destroy
      flash[:notice] = "コメントを削除しました"
      respond_to do |format|
        format.turbo_stream { render :destroy }
        format.html { redirect_to @learning_comment.study_log, notice: "コメントを削除しました" }
      end
    else
      flash[:alert] = "コメントの削除に失敗しました"
      respond_to do |format|
        format.turbo_stream { render :destroy_error }
        format.html { redirect_to @learning_comment.study_log, alert: "コメントの削除に失敗しました" }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream { render :edit }
      format.html { redirect_to @learning_comment.study_log }
    end
  end

  def update
    if @learning_comment.update(learning_comment_params.except(:study_log_id))
      flash[:notice] = "コメントを編集しました"
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @learning_comment.study_log, notice: "コメントを編集しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update_error }
        format.html { redirect_to @learning_comment.study_log, alert: "コメントの編集に失敗しました" }
      end
    end
  end

  private

  def set_learning_comment
    @learning_comment = current_user.learning_comments.find(params[:id])
  end

  def learning_comment_params
    params.require(:learning_comment).permit(:text, :study_log_id)
  end
end
