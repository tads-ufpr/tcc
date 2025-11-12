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
  end
end
