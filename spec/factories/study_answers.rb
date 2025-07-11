FactoryBot.define do
  factory :study_answer do
    association :study_challenge
    association :user
    user_answer { "サンプル回答" }
  end
end