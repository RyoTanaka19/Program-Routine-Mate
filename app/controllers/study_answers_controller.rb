class StudyAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_challenge_and_log

  def answer
    @study_answer = @study_challenge.study_answers.new
  end

  def submit_answer
    user_answer = study_answer_params[:user_answer]

    begin
      explanation = OpenAiService.explain_answer(@study_challenge.user_response, user_answer)
    rescue OpenAiService::ApiError => e  # OpenAiServiceで発生する可能性のあるエラー
      Rails.logger.error("API Error: #{e.message}")
      redirect_to answer_study_log_study_challenge_study_answers_path(@study_log, @study_challenge),
                  alert: t("study_answers.explanation_fetch_failed", error: e.message)
      return
    rescue StandardError => e  # その他のエラーをキャッチ
      Rails.logger.error("Unexpected Error: #{e.message}")
      redirect_to answer_study_log_study_challenge_study_answers_path(@study_log, @study_challenge),
                  alert: t("study_answers.explanation_fetch_failed", error: e.message)
      return
    end

    correct_answer = extract_correct_answer(@study_challenge.user_response)

    unless explanation.present? && correct_answer.present?
      redirect_to answer_study_log_study_challenge_study_answers_path(@study_log, @study_challenge),
                  alert: t("study_answers.explanation_missing")
      return
    end

    @study_answer = @study_challenge.study_answers.new(
      user_answer: user_answer,
      correct_answer: correct_answer,
      explanation: explanation,
      user: current_user
    )

    if @study_answer.save
      redirect_to result_study_log_study_challenge_study_answers_path(@study_log, @study_challenge)
    else
      Rails.logger.error("StudyAnswer Save Failed: #{@study_answer.errors.full_messages.join(', ')}")
      flash.now[:alert] = @study_answer.errors.full_messages.join("、")
      render :answer, status: :unprocessable_entity
    end
  end

  def result
    all_challenges = @study_log.study_challenges.includes(:study_answers)
    answers_by_challenge = StudyAnswer
                             .where(user: current_user, study_challenge: all_challenges.ids)
                             .order(created_at: :desc)
                             .group_by(&:study_challenge_id)

    @study_answer = answers_by_challenge[@study_challenge.id]&.first

    unless @study_answer
      redirect_to answer_study_log_study_challenge_study_answers_path(@study_log, @study_challenge),
                  alert: t("study_answers.answer_not_found")
      return
    end

    @user_answer = @study_answer.user_answer
    @correct_answer = @study_answer.correct_answer
    @explanation = @study_answer.explanation

    user_scores = all_challenges.map do |challenge|
      latest = answers_by_challenge[challenge.id]&.first
      latest&.user_answer == latest&.correct_answer ? 1 : 0
    end

    @score = user_scores.sum
    @total = all_challenges.count
  end

  def history
    @study_answers = current_user.study_answers.includes(:study_challenge).order(created_at: :desc)
  end

  private

  def set_study_challenge_and_log
    @study_challenge = StudyChallenge.find_by(id: params[:study_challenge_id])
    unless @study_challenge
      redirect_to study_logs_path, alert: t("study_answers.challenge_not_found")
    else
      @study_log = @study_challenge.study_log
    end
  end

  def study_answer_params
    params.require(:study_answer).permit(:user_answer)
  end

  def extract_correct_answer(response_text)
    matched = response_text.match(/正解:\s*([A-D])/)
    matched ? matched[1] : nil
  end
end
