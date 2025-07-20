class StudyChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log, except: [ :show, :answer, :submit_answer, :result ]

  def new
    # 「挑戦しますか？」と尋ねる画面
  end

  def create
    challenge = @study_log.study_challenges.build

    ai_question = "#{@study_log.study_genre}#{@study_log.content}\n#{@study_log.text}"
    user_response_text = OpenAiService.generate_question(ai_question, type: :multiple_choice)

    if user_response_text.present?
      challenge.ai_question = ai_question
      challenge.user_response = user_response_text
      challenge.save!
      redirect_to study_challenge_path(challenge), notice: "あなたに合った問題を出題しました！"
    else
      redirect_to study_logs_path, alert: "問題の生成に失敗しました。"
    end
  end

  def show
    @study_challenge = StudyChallenge.find(params[:id])
    @study_log = @study_challenge.study_log
    @question_only = extract_question(@study_challenge.user_response)
  end

  def answer
    @study_challenge = StudyChallenge.find(params[:id])
    @study_log = @study_challenge.study_log
    @study_answer = @study_challenge.study_answers.new
  end

  def submit_answer
    @study_challenge = StudyChallenge.find(params[:id])
    @study_log = @study_challenge.study_log
    user_answer = params[:user_answer]

    explanation = OpenAiService.explain_answer(@study_challenge.user_response, user_answer)
    correct_answer = extract_correct_answer(@study_challenge.user_response)

    unless explanation.present? && correct_answer.present?
      redirect_to answer_study_log_study_challenge_path(@study_log, @study_challenge),
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
      redirect_to result_study_log_study_challenge_path(@study_log, @study_challenge)
    else
      flash.now[:alert] = "回答の保存に失敗しました。"
      render :answer
    end
  end

  def result
    @study_challenge = StudyChallenge.find(params[:id])
    @study_log = @study_challenge.study_log

    @study_answer = @study_challenge.study_answers.where(user: current_user).order(created_at: :desc).first

    unless @study_answer
      redirect_to answer_study_log_study_challenge_path(@study_log, @study_challenge), alert: "回答が見つかりません。"
      return
    end

    @user_answer = @study_answer.user_answer
    @correct_answer = @study_answer.correct_answer
    @explanation = @study_answer.explanation

    all_challenges = @study_log.study_challenges

    user_scores = all_challenges.map do |challenge|
      latest_answer = challenge.study_answers.where(user: current_user).order(created_at: :desc).first
      next 0 unless latest_answer

      latest_answer.user_answer == latest_answer.correct_answer ? 1 : 0
    end

    @score = user_scores.sum
    @total = all_challenges.count
  end

  private

  def extract_question(text)
    text.gsub(/^正解:.*$/i, "").strip
  end

  def extract_correct_answer(response_text)
    matched = response_text.match(/^正解:\s*([A-D])/)
    matched ? matched[1] : nil
  end

  def set_study_log
    @study_log = current_user.study_logs.find(params[:study_log_id])
  end
end
