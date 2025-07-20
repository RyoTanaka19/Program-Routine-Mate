class StudyCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_comment, only: [ :edit, :update, :destroy ]

  def create
    @study_log = StudyLog.find(params[:study_log_id])
    @study_comment = current_user.study_comments.build(study_comment_params)
    @study_comment.study_log = @study_log

    if @study_comment.save
      flash[:notice] = "コメントを投稿しました"
      CommentNotificationJob.perform_later(@study_comment.id) if @study_comment.study_log.user != current_user

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
    if @study_comment.destroy
      flash[:notice] = "コメントを削除しました"
      respond_to do |format|
        format.turbo_stream { render :destroy }
        format.html { redirect_to @study_comment.study_log, notice: "コメントを削除しました" }
      end
    else
      flash[:alert] = "コメントの削除に失敗しました"
      respond_to do |format|
        format.turbo_stream { render :destroy_error }
        format.html { redirect_to @study_comment.study_log, alert: "コメントの削除に失敗しました" }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream { render :edit }
      format.html { redirect_to @study_comment.study_log }
    end
  end

  def update
    if @study_comment.update(study_comment_params.except(:study_log_id))
      flash[:notice] = "コメントを編集しました"
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @study_comment.study_log, notice: "コメントを編集しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update_error }
        format.html { redirect_to @study_comment.study_log, alert: "コメントの編集に失敗しました" }
      end
    end
  end

  private

  def set_study_comment
    @study_comment = current_user.study_comments.find(params[:id])
  end

  def study_comment_params
    params.require(:study_comment).permit(:text, :study_log_id)
  end
end
