require 'rails_helper'

RSpec.describe "StudyReminders", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /study_reminders" do
    it "リクエストが成功し、インスタンス変数がセットされる" do
      reminder = create(:study_reminder, user: user)
      log = create(:study_log, user: user, date: Date.today)

      get study_reminders_path

      expect(response).to have_http_status(:ok)
      expect(assigns(:study_reminders)).to include(reminder)
      expect(assigns(:study_logs)).to include(log)
    end
  end

  describe "GET /study_reminders/new" do
    context "dateパラメータがある場合" do
      it "指定日のstart_timeとend_timeが設定される" do
        get new_study_reminder_path(date: "2025-07-11")

        expect(response).to have_http_status(:ok)
        reminder = assigns(:study_reminder)
        expect(reminder.start_time).to eq(Time.zone.local(2025, 7, 11, 0, 0, 0))
        expect(reminder.end_time).to eq(reminder.start_time)
      end
    end

    context "dateパラメータがない場合" do
      it "start_timeがnilであること" do
        get new_study_reminder_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:study_reminder).start_time).to be_nil
      end
    end
  end

  describe "POST /study_reminders" do
    context "有効なパラメータの場合" do
      it "リマインダーが作成される" do
        valid_params = {
          study_reminder: {
            title: "勉強時間",
            start_time: Time.zone.now,
            end_time: 1.hour.from_now
          }
        }

        expect {
          post study_reminders_path, params: valid_params
        }.to change(user.study_reminders, :count).by(1)

        expect(response).to redirect_to(study_reminders_path)
        follow_redirect!
        expect(response.body).to include("学習開始時間と学習終了時間が設定されました")
      end
    end

    context "無効なパラメータの場合（end_timeが空）" do
      it "バリデーションエラーが表示され、formが再描画される" do
        invalid_params = {
          study_reminder: {
            title: "失敗テスト",
            start_time: Time.zone.now,
            end_time: nil
          }
        }

        post study_reminders_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("study-reminder-form") # turbo_streamで置換される要素
      end
    end
  end
end
