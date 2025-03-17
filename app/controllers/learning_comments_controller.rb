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
    respond_to do |format|
      if @learning_comment.update(learning_comment_params)
        format.turbo_stream
        format.html { redirect_to root_path, notice: "コメントが更新されました" }
      else
        Rails.logger.debug @learning_comment.errors.full_messages
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
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
