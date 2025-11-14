FactoryBot.define do
  factory :apartment do
    association :condominium

    status { 0 }
    floor { Faker::Number.number(digits: 1) }
    number { Faker::Address.secondary_address }
    tower { Faker::Address.mail_box }

    trait :approved do
      status { 1 }
    end

    trait :with_residents do
      transient do
        residents_count { 1 }
        owner_exists { true }
      end

      after(:create) do |apartment, evaluator|
        if evaluator.owner_exists
          create(:resident, apartment: apartment, user: create(:user), owner: true)
          (evaluator.residents_count - 1).times do
            create(:resident, apartment: apartment, user: create(:user), owner: false)
          end
        else
          create_list(:resident, evaluator.residents_count, apartment: apartment, owner: false)
        end
      end
    end
  end
end
