class LikesController < ApplicationController
  def create
    @study_log = StudyLog.find(params[:study_log_id])
    @like = @study_log.likes.build(user: current_user)

    if @like.save
      respond_to do |format|
        format.html { redirect_to study_logs_path, notice: "いいねしました！" }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("like-button-#{@study_log.id}", partial: "study_logs/like_button", locals: { study_log: @study_log }),
            turbo_stream.update("like-count-#{@study_log.id}", "<p>いいねの数: #{@study_log.likes.count}</p>")
          ]
        end
      end
    else
      redirect_to study_logs_path, alert: "いいねできませんでした。"
    end
  end

  def destroy
    @study_log = StudyLog.find(params[:study_log_id])
    @like = @study_log.likes.find_by(user: current_user)

    if @like
      @like.destroy
      respond_to do |format|
        format.html { redirect_to study_logs_path, notice: "いいねを取り消しました。" }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("like-button-#{@study_log.id}", partial: "study_logs/like_button", locals: { study_log: @study_log }),
            turbo_stream.update("like-count-#{@study_log.id}", "<p>いいねの数: #{@study_log.likes.count}</p>")
          ]
        end
      end
    else
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end
end
