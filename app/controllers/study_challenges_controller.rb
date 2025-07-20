class StudyChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_log, only: [:new, :create]

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

  private

  def set_study_log
    @study_log = current_user.study_logs.find(params[:study_log_id])
  end

  def extract_question(text)
    text.gsub(/^正解:.*$/i, "").strip
  end
end
