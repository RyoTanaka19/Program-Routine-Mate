class StudyLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log
  before_action :set_study_like, only: [:destroy]

  def create
    # 既にいいね済みか確認（あれば早期リダイレクト）
    if @study_log.study_likes.exists?(user: current_user)
      redirect_to @study_log, alert: "すでにいいねしています。"
      return
    end

    notice_message = "いいねしました！"
    study_like = @study_log.study_likes.build(user: current_user)

    if study_like.save
      LikeNotificationJob.perform_later(@study_log.id, current_user.id)
      respond_to do |format|
        format.html do
          flash[:notice] = notice_message
          redirect_to @study_log   # ← リダイレクト先を動的に
        end
        format.turbo_stream do
          flash.now[:notice] = notice_message
          render :create
        end
      end
    else
      redirect_to @study_log, alert: "いいねできませんでした。"
    end
  end

  def destroy
    # find_by!にして見つからなければ404にする
    # （例外をrescueしない限りはRailsが404ページを返す）
    @study_like.destroy
    notice_message = "いいねを取り消しました。"

    respond_to do |format|
      format.html do
        flash[:notice] = notice_message
        redirect_to @study_log    # ← リダイレクト先を動的に
      end
      format.turbo_stream do
        flash.now[:notice] = notice_message
        render :destroy
      end
    end
  end

  private

  def set_study_log
    @study_log = StudyLog.find(params[:study_log_id])
  end

  def set_study_like
    # find_by! に変更：見つからなければActiveRecord::RecordNotFound（404）
    @study_like = @study_log.study_likes.find_by!(user: current_user)
  end
end
