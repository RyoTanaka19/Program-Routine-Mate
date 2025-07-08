FactoryBot.define do
  factory :study_log do
    association :user
    association :study_genre
    content { "勉強した内容" }
    text { "詳細な内容" }
    date { Date.today }

    # study_reminder は任意（optional）
    study_reminder { nil }
  end
end
