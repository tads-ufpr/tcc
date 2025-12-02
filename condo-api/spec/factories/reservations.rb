FactoryBot.define do
  factory :reservation do
    association :facility
    association :apartment
    association :creator, factory: :user
    scheduled_date { Date.today + 1.week }
  end
end
