require 'rails_helper'

RSpec.describe StudyGenre, type: :model do
  let(:user) { create(:user) }
  let(:valid_name) { StudyGenre::GENRES.values.first } # ← 安定して使える値を定義

  describe 'バリデーション' do
    it '有効なファクトリを持つこと' do
      genre = build(:study_genre, user: user)
      expect(genre).to be_valid
    end

    it '名前がなければ無効' do
      genre = build(:study_genre, name: nil, user: user)
      expect(genre).to be_invalid
      expect(genre.errors[:name]).to include("を入力してください")
    end

    it '名前が重複していたら無効（同一ユーザー）' do
      create(:study_genre, name: valid_name, user: user)
      duplicate = build(:study_genre, name: valid_name, user: user)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:name]).to include("はすでに登録されています。")
    end

    it '同じ名前でも別ユーザーなら有効' do
      create(:study_genre, name: valid_name, user: user)
      other_user = create(:user)
      genre = build(:study_genre, name: valid_name, user: other_user)
      expect(genre).to be_valid
    end

    it '定義されたジャンル以外は無効' do
      genre = build(:study_genre, name: "未知ジャンル", user: user)
      expect(genre).to be_invalid
      expect(genre.errors[:name]).to include("は一覧にありません")
    end
  end

  describe '#study_log_count' do
    it '関連するstudy_logsの数を返すこと' do
      genre = create(:study_genre, user: user)
      create_list(:study_log, 3, study_genre: genre, user: user)

      expect(genre.study_log_count).to eq(3)
    end
  end
end
