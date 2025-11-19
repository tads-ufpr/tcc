FactoryBot.define do
  factory :employee do
    association :user
    association :condominium

    role { :colaborator }
    description { Faker::Job.title }

    trait :admin do
      role { :admin }
    end

    trait :colaborator do
      role { :colaborator }
    end
  end
end
