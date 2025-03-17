class LearningCommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy, :edit, :update ]

  def edit
    @learning_comment = LearningComment.find(params[:id])
  end

  def create
    @learning_comment = current_user.learning_comments.build(learning_comment_params)
    @learning_comment.save
  end

  def update
    @learning_comment = LearningComment.find(params[:id])
    @learning_comment.update(learning_comment_params)
  end


  def destroy
     @learning_comment = current_user.learning_comments.find(params[:id])
     @learning_comment.destroy!
  end

  private

  def learning_comment_params
    params.require(:learning_comment).permit(:text).merge(study_log_id: params[:study_log_id])
  end
end
