FactoryBot.define do
  factory :study_genre do
    association :user
    name { "Ruby" }  # GENRESの中から1つ指定
  end
end
