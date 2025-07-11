# spec/models/study_answer_spec.rb
require 'rails_helper'

RSpec.describe StudyAnswer, type: :model do
  describe 'アソシエーション' do
    it 'study_challengeに属していること' do
      assoc = described_class.reflect_on_association(:study_challenge)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'userに属していること' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe 'バリデーション' do
    it 'user_answerがなければ無効' do
      answer = build(:study_answer, user_answer: nil)
      answer.validate
      expect(answer.errors[:user_answer]).to include("を入力してください")
    end

    it 'user_answerがあれば有効' do
      answer = build(:study_answer, user_answer: "回答例")
      expect(answer).to be_valid
    end
  end
end
