require 'rails_helper'

RSpec.describe "StudyLogs", type: :request do
  let(:user) { create(:user) }
  let(:study_genre) { create(:study_genre, user: user) }
  let(:study_log) { create(:study_log, user: user, study_genre: study_genre) }

  describe "GET /new" do
    context "ログインしている場合" do
      before { sign_in user }

      it "新規作成ページが表示される" do
        # ジャンルが存在することを担保
        study_genre
        get new_study_log_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("form") # フォームが含まれるか簡易チェック
      end

      it "ジャンルがない場合はリダイレクトされる" do
        # ジャンルを作らずにアクセス
        get new_study_log_path
        expect(response).to redirect_to(new_study_genre_path)
        follow_redirect!
        expect(response.body).to include("ジャンルを先に設定してください")
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get new_study_log_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /create" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          study_log: {
            content: "学習内容",
            text: "詳細説明",
            study_genre_id: study_genre.id,
            date: Date.today
          }
        }
      end

      it "学習記録が作成される" do
        expect {
          post study_logs_path, params: valid_params
        }.to change(StudyLog, :count).by(1)

        expect(response).to redirect_to(new_study_log_study_challenge_path(StudyLog.last))
        follow_redirect!
        expect(response.body).to include("学習記録が作成されました")
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        {
          study_log: {
            content: "", # contentは必須のはず
            study_genre_id: study_genre.id,
            date: Date.today
          }
        }
      end

      it "作成に失敗してnewテンプレートを再表示" do
        post study_logs_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("学習記録の作成に失敗しました")
      end
    end

    context "study_genre_idが無効な場合" do
      let(:params_with_invalid_genre) do
        {
          study_log: {
            content: "学習内容",
            study_genre_id: 999999, # 存在しないID
            date: Date.today
          }
        }
      end

      it "エラーメッセージを表示してnewテンプレート再表示" do
        post study_logs_path, params: params_with_invalid_genre
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("指定された学習ジャンルが見つかりませんでした")
      end
    end
  end

  describe "GET /index" do
    it "投稿一覧が表示される" do
      get study_logs_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("学習記録一覧") # あなたのビューに応じて変更してください
    end
  end

  describe "DELETE /destroy" do
    before { sign_in user }
    let!(:study_log) { create(:study_log, user: user, study_genre: study_genre) }

    it "学習記録を削除できる" do
      expect {
        delete study_log_path(study_log)
      }.to change(StudyLog, :count).by(-1)
      expect(response).to redirect_to(study_logs_path)
      follow_redirect!
      expect(response.body).to include("学習記録の削除をしました")
    end
  end
end
