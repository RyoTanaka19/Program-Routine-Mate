FactoryBot.define do
  factory :study_genre do
    association :user
    name { StudyGenre::GENRES.values.sample } # ← ハッシュの値からランダムに選択
  end
end
