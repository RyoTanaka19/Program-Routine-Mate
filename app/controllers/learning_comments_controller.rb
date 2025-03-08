class LearningCommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]

  def create
    @learning_comment = current_user.learning_comments.build(learning_comment_params)
    @learning_comment.save
  end

  def destroy
     @learning_comment = current_user.learning_comments.find(params[:id])
     @learning_comment.destroy!
  end

  private

  def learning_comment_params
    params.require(:learning_comment).permit(:text).merge(study_log_id: params[:study_log_id])
  end

  def learning_comment_update_params
    params.require(:learning_comment).permit(:text)
  end
end
