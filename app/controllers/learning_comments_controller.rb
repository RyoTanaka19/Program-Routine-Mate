class LearningCommentsController < ApplicationController
  def create
    learning_comment = current_user.learning_comments.build(learning_comment_params)
    if learning_comment.save
      redirect_to study_logs_path(learning_comment.study_log)
    else
      redirect_to study_logs_path(learning_comment.study_log)
    end
  end

  private

  def learning_comment_params
    params.require(:learning_comment).permit(:text).merge(study_log_id: params[:study_log_id])
  end
end
