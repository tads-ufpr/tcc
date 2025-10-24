FactoryBot.define do
  factory :notice do
    transient do
      condominium { create(:condominium) }
    end

    apartment { create(:apartment, condominium:) }
    creator { create(:employee, condominium:) }

    description { Faker::Lorem.sentence }
    title { Faker::Lorem.word }
    type_info { Faker::Lorem.sentence }

    trait :delivery do
      notice_type { :delivery }
    end

    trait :visitor do
      notice_type { :visitor }
    end

    trait :maintenance do
      notice_type { :maintenance }
    end

    trait :communication do
      notice_type { :communication }
    end

    trait :pending do
      status { :pending }
    end

    trait :acknowledged do
      status { :acknowledged }
    end

    trait :resolved do
      status { :resolved }
    end

    trait :blocked do
      status { :blocked }
    end
  end
end
