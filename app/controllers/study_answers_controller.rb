class StudyAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_challenge_and_log

  def answer
    @study_answer = @study_challenge.study_answers.new
  end

  def submit_answer
    user_answer = params[:user_answer]

    explanation = OpenAiService.explain_answer(@study_challenge.user_response, user_answer)
    correct_answer = extract_correct_answer(@study_challenge.user_response)

    unless explanation.present? && correct_answer.present?
      redirect_to answer_study_log_study_challenge_study_answers_path(@study_log, @study_challenge),
                  alert: "解説の取得に失敗しました。"
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
      flash.now[:alert] = "回答の保存に失敗しました。"
      render :answer
    end
  end

  def result
    @study_answer = @study_challenge.study_answers.where(user: current_user).order(created_at: :desc).first

    unless @study_answer
      redirect_to answer_study_log_study_challenge_study_answers_path(@study_log, @study_challenge), alert: "回答が見つかりません。"
      return
    end

    @user_answer = @study_answer.user_answer
    @correct_answer = @study_answer.correct_answer
    @explanation = @study_answer.explanation

    all_challenges = @study_log.study_challenges
    user_scores = all_challenges.map do |challenge|
      latest_answer = challenge.study_answers.where(user: current_user).order(created_at: :desc).first
      latest_answer&.user_answer == latest_answer&.correct_answer ? 1 : 0
    end

    @score = user_scores.sum
    @total = all_challenges.count
  end

  private

  def set_study_challenge_and_log
    @study_challenge = StudyChallenge.find(params[:study_challenge_id])
    @study_log = @study_challenge.study_log
  end

  def extract_correct_answer(response_text)
    matched = response_text.match(/^正解:\s*([A-D])/)
    matched ? matched[1] : nil
  end
end
