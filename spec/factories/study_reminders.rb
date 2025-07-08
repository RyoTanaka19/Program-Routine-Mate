FactoryBot.define do
  factory :study_reminder do
    association :user
    start_time { Time.current + 1.hour }
    end_time { Time.current + 2.hours }
  end
end
