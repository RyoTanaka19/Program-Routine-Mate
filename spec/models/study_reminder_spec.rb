require 'rails_helper'

RSpec.describe StudyReminder, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  describe 'バリデーション' do
    it '有効なファクトリを持つこと' do
      reminder = build(:study_reminder, user: user)
      expect(reminder).to be_valid
    end

    it 'start_timeがなければ無効' do
      reminder = build(:study_reminder, start_time: nil, user: user)
      reminder.validate
      expect(reminder.errors[:start_time]).to include("を入力してください")
    end

    it 'end_timeがなければ無効' do
      reminder = build(:study_reminder, end_time: nil, user: user)
      reminder.validate
      expect(reminder.errors[:end_time]).to include("を入力してください")
    end

    it 'start_timeが現在より前だと無効' do
      travel_to Time.current do
        reminder = build(:study_reminder, start_time: 1.minute.ago, end_time: 1.hour.from_now, user: user)
        reminder.validate
        expect(reminder.errors[:start_time]).to include("現在の時間以降で設定してください")
      end
    end

    it 'end_timeがstart_timeと同じだと無効' do
      time = Time.current + 1.hour
      reminder = build(:study_reminder, start_time: time, end_time: time, user: user)
      reminder.validate
      expect(reminder.errors[:end_time]).to include("学習開始時間と学習終了時間が同じです。時間を変更してください")
    end

    it 'end_timeがstart_timeより前だと無効' do
      reminder = build(:study_reminder, start_time: Time.current + 2.hours, end_time: Time.current + 1.hour, user: user)
      reminder.validate
      expect(reminder.errors[:end_time]).to include("終了時間は開始時間より後に設定してください")
    end
  end
end
