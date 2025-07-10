class LikesController < ApplicationController
  def create
    @study_log = StudyLog.find(params[:study_log_id])
    @like = @study_log.likes.build(user: current_user)

    if @like.save
      # いいね成功時に通知を送信
      NotifyUserJob.perform_later(
        learning_comment_id: nil,  # コメントではないのでnil
        study_log_id: @study_log.id,  # 学習記録のID
        user_id: @study_log.user.id # 学習記録の所有者ID
      )

      respond_to do |format|
        format.html do
          flash[:notice] = "いいねしました！"
          redirect_to study_logs_path
        end
        format.turbo_stream do
          flash.now[:notice] = "いいねしました！"  # turbo_streamの場合はflash.nowを使用

          render turbo_stream: [
            turbo_stream.replace(
              "like-button-#{@study_log.id}",
              partial: "study_logs/like_button",
              locals: { study_log: @study_log }
            ),
            turbo_stream.update(
              "like-count-#{@study_log.id}",
              "<p>いいねの数: #{@study_log.likes.count}</p>"
            ),
            # フラッシュメッセージを更新
            turbo_stream.replace(
              "flash_messages",
              partial: "shared/flash_messages" # フラッシュメッセージを更新
            )
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
        format.html do
          flash[:notice] = "いいねを取り消しました。"
          redirect_to study_logs_path
        end
        format.turbo_stream do
          flash.now[:notice] = "いいねを取り消しました。"  # turbo_streamの場合はflash.nowを使用

          render turbo_stream: [
            turbo_stream.replace(
              "like-button-#{@study_log.id}",
              partial: "study_logs/like_button",
              locals: { study_log: @study_log }
            ),
            turbo_stream.update(
              "like-count-#{@study_log.id}",
              "<p>いいねの数: #{@study_log.likes.count}</p>"
            ),
            # フラッシュメッセージを更新
            turbo_stream.replace(
              "flash_messages",
              partial: "shared/flash_messages" # フラッシュメッセージを更新
            )
          ]
        end
      end
    else
      redirect_to study_logs_path, alert: "いいねが見つかりません。"
    end
  end
end
