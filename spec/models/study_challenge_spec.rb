# spec/models/study_challenge_spec.rb
require 'rails_helper'

RSpec.describe StudyChallenge, type: :model do
  describe 'アソシエーション' do
    it '複数のstudy_answersを持つこと' do
      assoc = described_class.reflect_on_association(:study_answers)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:dependent]).to eq :destroy
    end

    it 'study_logに属していること' do
      assoc = described_class.reflect_on_association(:study_log)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end
