require 'rails_helper'

RSpec.describe "StudyGenres", type: :request do
  let(:user) { create(:user) }                     # ログインユーザー用
  let(:other_user) { create(:user) }               # 別ユーザー用
  let!(:study_genre) { create(:study_genre, user: user, name: "Ruby") }
  let!(:other_study_genre) { create(:study_genre, user: other_user, name: "プログラミング") }

  describe "GET /index" do
    it "正常にレスポンスが返ること" do
      get study_genres_path
      expect(response).to have_http_status(:ok)
    end

    it "ジャンルの統計情報がassignされていること" do
      get study_genres_path
      expect(assigns(:genre_stats)).to be_present
    end
  end

  describe "GET /new" do
    context "ログインユーザーの場合" do
      before do
        sign_in user
      end

      it "正常にレスポンスが返ること" do
        get new_study_genre_path
        expect(response).to have_http_status(:ok)
      end

      it "@study_genresがユーザーのものを含むこと" do
        get new_study_genre_path
        expect(assigns(:study_genres)).to include(study_genre)
      end
    end

    context "未ログインユーザーの場合" do
      it "ログインページへリダイレクトされること" do
        get new_study_genre_path
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("ログインが必要です。")
      end
    end
  end

  describe "POST /create" do
    before { sign_in user }

    context "条件を満たして新規作成可能な場合" do
      before do
        # userに21日分以上のstudy_logsを用意して条件クリア
        21.times do |i|
          create(:study_log, user: user, study_genre: study_genre, created_at: i.days.ago)
        end
      end

      it "ジャンルが作成されリダイレクトされること" do
        expect {
          post study_genres_path, params: { study_genre: { name: "JavaScript" } }
        }.to change(StudyGenre, :count).by(1)

        expect(response).to redirect_to(new_study_log_path(study_genre_id: StudyGenre.last.id))
        expect(flash[:notice]).to eq("ジャンルが設定されました。")
      end
    end

    context "既に同じ名前のジャンルがある場合" do
      it "エラーメッセージが表示されること" do
        post study_genres_path, params: { study_genre: { name: "Ruby" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("すでに設定しているジャンルは設定できません。")
      end
    end

    context "21日分のログ条件を満たさない場合" do
      it "エラーメッセージが表示されること" do
        post study_genres_path, params: { study_genre: { name: "NewGenre" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("新しいジャンルを設定する条件が満たされていません。")
      end
    end
  end

  describe "GET /edit" do
    context "自分のジャンルの場合" do
      before { sign_in user }

      it "正常にレスポンスが返ること" do
        get edit_study_genre_path(study_genre)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他人のジャンルの場合" do
      before { sign_in user }

      it "リダイレクトされること" do
        get edit_study_genre_path(other_study_genre)
        expect(response).to redirect_to(study_genres_path)
        expect(flash[:alert]).to eq("アクセス権限がありません。")
      end
    end
  end

  describe "PATCH /update" do
    before { sign_in user }

    context "正常に更新できる場合" do
      it "名前が変更されリダイレクトされること" do
        patch study_genre_path(study_genre), params: { study_genre: { name: "NewName" } }

        expect(response).to redirect_to(new_study_log_path(study_genre_id: study_genre.id))
        expect(flash[:notice]).to eq("ジャンルが更新されました。")

        study_genre.reload
        expect(study_genre.name).to eq("NewName")
      end
    end

    context "他のジャンルと名前が重複する場合" do
      it "エラーが表示されること" do
        patch study_genre_path(study_genre), params: { study_genre: { name: other_study_genre.name } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("他で設定しているジャンルと同じ名前は設定できません。")
      end
    end

    context "アクセス権限がない場合" do
      it "リダイレクトされること" do
        patch study_genre_path(other_study_genre), params: { study_genre: { name: "Hoge" } }

        expect(response).to redirect_to(study_genres_path)
        expect(flash[:alert]).to eq("アクセス権限がありません。")
      end
    end
  end

  describe "GET /show" do
    context "自分のジャンルの場合" do
      before { sign_in user }

      it "正常に表示されること" do
        get study_genre_path(study_genre)
        expect(response).to have_http_status(:ok)
      end
    end

    context "ジャンルが存在しない場合" do
      before { sign_in user }

      it "リダイレクトされること" do
        get study_genre_path(9999)
        expect(response).to redirect_to(study_genres_path)
        expect(flash[:alert]).to eq("指定されたジャンルは見つかりません。")
      end
    end

    context "アクセス権限がない場合" do
      before { sign_in user }

      it "indexがrenderされること" do
        get study_genre_path(other_study_genre)
        expect(response).to render_template(:index)
        expect(flash[:alert]).to eq("アクセス権限がありません。")
      end
    end
  end
end
