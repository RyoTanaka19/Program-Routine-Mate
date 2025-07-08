require 'rails_helper'

RSpec.describe StudyLog, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:study_genre) { create(:study_genre, user: user) }

  describe 'バリデーション' do
    it '有効なファクトリを持つこと' do
      log = build(:study_log, user: user, study_genre: study_genre)
      expect(log).to be_valid
    end

    it 'contentがなければ無効' do
      log = build(:study_log, content: nil, user: user, study_genre: study_genre)
      log.validate
      expect(log.errors[:content]).to include("学習内容を入力してください")
    end

    it 'textがなければ無効' do
      log = build(:study_log, text: nil, user: user, study_genre: study_genre)
      log.validate
      expect(log.errors[:text]).to include("感想などを入力してください")
    end

    it 'dateがなければ無効' do
      log = build(:study_log, date: nil, user: user, study_genre: study_genre)
      log.validate
      expect(log.errors[:date]).to include("を入力してください")
    end
  end

  describe 'アソシエーション' do
    it 'userに属している' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'study_genreに属している' do
      assoc = described_class.reflect_on_association(:study_genre)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'likesを複数持つ' do
      assoc = described_class.reflect_on_association(:likes)
      expect(assoc.macro).to eq :has_many
    end

    it 'liked_usersを持つ' do
      assoc = described_class.reflect_on_association(:liked_users)
      expect(assoc.macro).to eq :has_many
    end

    it 'learning_commentsを複数持つ' do
      assoc = described_class.reflect_on_association(:learning_comments)
      expect(assoc.macro).to eq :has_many
    end
  end

  describe '#calculate_study_duration（コールバック）' do
    it 'study_reminderがない場合はtotalがnilのまま' do
      log = build(:study_log, study_reminder: nil, user: user, study_genre: study_genre)
      log.save
      expect(log.total).to be_nil
    end

    it '現在時刻がリマインダー時間内ならtotalが設定される' do
      start_time = Time.current + 1.minute
      end_time = Time.current + 10.minutes
      reminder = create(:study_reminder, user: user, start_time: start_time, end_time: end_time)

      travel_to(start_time + 1.minute) do
        log = create(:study_log, study_reminder: reminder, user: user, study_genre: study_genre)
        expect(log.total).to be >= 0
      end
    end

    it '現在時刻がリマインダー時間外ならtotalはnilになる' do
      start_time = Time.current + 10.minutes
      end_time = Time.current + 20.minutes
      reminder = create(:study_reminder, user: user, start_time: start_time, end_time: end_time)

      travel_to(Time.current) do
        log = create(:study_log, study_reminder: reminder, user: user, study_genre: study_genre)
        expect(log.total).to be_nil
      end
    end
  end
end
