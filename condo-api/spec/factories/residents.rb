FactoryBot.define do
  factory :resident do
    association :user
    association :apartment
  end
end
