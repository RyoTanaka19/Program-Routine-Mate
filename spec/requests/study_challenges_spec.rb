require 'rails_helper'

RSpec.describe "StudyChallenges", type: :request do
  let(:user) { create(:user) }
  let(:study_genre) { create(:study_genre, user: user) }
  let(:study_log) { create(:study_log, user: user, study_genre: study_genre) }
  let!(:study_challenge) { create(:study_challenge, study_log: study_log) }

  before do
    sign_in user
  end

  describe "GET /study_logs/:study_log_id/study_challenges/new" do
    it "レスポンスが成功すること" do
      get new_study_log_study_challenge_path(study_log)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /study_logs/:study_log_id/study_challenges" do
    context "OpenAiService.generate_question が問題文を返す場合" do
      before do
        allow(OpenAiService).to receive(:generate_question).and_return("問題文\n正解:A")
      end

      it "チャレンジが作成されリダイレクトされること" do
        post study_log_study_challenges_path(study_log)

        challenge = StudyChallenge.last
        expect(response).to redirect_to(study_challenge_path(challenge))
        follow_redirect!
        expect(response.body).to include("あなたに合った問題を出題しました！")
      end
    end

    context "OpenAiService.generate_question がnilを返す場合" do
      before do
        allow(OpenAiService).to receive(:generate_question).and_return(nil)
      end

      it "問題生成失敗のフラッシュとstudy_logsへリダイレクトされること" do
        post study_log_study_challenges_path(study_log)
        expect(response).to redirect_to(study_logs_path)
        follow_redirect!
        expect(response.body).to include("問題の生成に失敗しました。")
      end
    end
  end

  describe "GET /study_challenges/:id" do
    it "showページが成功し質問文が表示されること" do
      get study_challenge_path(study_challenge)

      expect(response).to have_http_status(:ok)
      # 問題文抽出ロジックを期待した値でテスト
      expect(response.body).to include(study_challenge.prompt || "")
    end
  end

  describe "GET /study_challenges/:id/answer" do
    it "answerページが成功しフォームが表示されること" do
      get answer_study_challenge_path(study_challenge)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("form") # 簡易的にフォームがあるかどうかだけ
    end
  end

  describe "POST /study_challenges/:id/submit_answer" do
    let(:valid_params) { { user_answer: "A" } }

    context "OpenAiService.explain_answer と正解が取得できる場合" do
      before do
        allow(OpenAiService).to receive(:explain_answer).and_return("解説です")
        allow_any_instance_of(StudyChallengesController).to receive(:extract_correct_answer).and_return("A")
      end

      it "回答が保存されリダイレクトされること" do
        post submit_answer_study_challenge_path(study_challenge), params: valid_params

        expect(response).to redirect_to(result_study_log_study_challenge_path(study_log, study_challenge))
        expect(StudyAnswer.last.user_answer).to eq("A")
      end
    end

    context "解説または正解が取れない場合" do
      before do
        allow(OpenAiService).to receive(:explain_answer).and_return(nil)
        allow_any_instance_of(StudyChallengesController).to receive(:extract_correct_answer).and_return(nil)
      end

      it "answer画面へalert付きでリダイレクトすること" do
        post submit_answer_study_challenge_path(study_challenge), params: valid_params

        expect(response).to redirect_to(answer_study_log_study_challenge_path(study_log, study_challenge))
        follow_redirect!
        expect(response.body).to include("解説の取得に失敗しました。")
      end
    end

    context "回答の保存に失敗する場合" do
      before do
        allow(OpenAiService).to receive(:explain_answer).and_return("解説です")
        allow_any_instance_of(StudyChallengesController).to receive(:extract_correct_answer).and_return("A")
        # 保存失敗のためバリデーションエラーを強制発生
        allow_any_instance_of(StudyChallenge).to receive_message_chain(:study_answers, :new).and_return(
          double(save: false)
        )
      end

      it "answerテンプレートが再描画されること" do
        post submit_answer_study_challenge_path(study_challenge), params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("回答の保存に失敗しました。")
      end
    end
  end

  describe "GET /study_challenges/:id/result" do
    context "回答がある場合" do
      before do
        create(:study_answer, study_challenge: study_challenge, user: user, user_answer: "A", correct_answer: "A", explanation: "解説")
      end

      it "結果ページが表示され点数が計算されていること" do
        get result_study_log_study_challenge_path(study_log, study_challenge)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("解説")
      end
    end

    context "回答がない場合" do
      it "answerページへalert付きでリダイレクトすること" do
        get result_study_log_study_challenge_path(study_log, study_challenge)

        expect(response).to redirect_to(answer_study_log_study_challenge_path(study_log, study_challenge))
        follow_redirect!
        expect(response.body).to include("回答が見つかりません。")
      end
    end
  end
end
