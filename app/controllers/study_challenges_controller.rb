class StudyChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log, only: [:new, :create]

  def new
    # 「挑戦しますか？」と尋ねる画面
  end

  def create
    ai_prompt = @study_log.ai_prompt
    user_response_text = OpenAiService.generate_question(ai_prompt, type: :multiple_choice)

    if user_response_text.blank?
      Rails.logger.warn("[AI生成失敗] study_log_id=#{@study_log.id}, prompt=#{ai_prompt}")
      redirect_to study_logs_path, alert: "問題の生成に失敗しました。"
      return
    end

    study_challenge = @study_log.study_challenges.build(
      ai_question: ai_prompt,
      user_response: user_response_text
    )

    if study_challenge.save
      redirect_to study_challenge_path(study_challenge), notice: "あなたに合った問題を出題しました！"
    else
      Rails.logger.error("[保存失敗] study_challenge=#{study_challenge.inspect}")
      redirect_to study_logs_path, alert: "問題の保存に失敗しました。"
    end
  end

def show
  @study_challenge = current_user.study_challenges.find(params[:id])
  @study_log = @study_challenge.study_log
  @question_only = @study_challenge.question_text
end

  private

  def set_study_log
    @study_log = current_user.study_logs.find(params[:study_log_id])
  end
end
