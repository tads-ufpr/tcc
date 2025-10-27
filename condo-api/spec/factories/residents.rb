FactoryBot.define do
  factory :resident do
    association :user
    association :apartment

    owner { false }
  end
end
