FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    email { Faker::Internet.unique.email }  # ユニークなメールを生成
    password { "password123" }
    password_confirmation { "password123" }
    provider { "github" }                    # もしproviderがあれば固定値でOK
    sequence(:uid) { |n| "uid#{n}" }         # uidを連番でユニークに
  end
end
