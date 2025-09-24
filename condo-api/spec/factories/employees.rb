FactoryBot.define do
  factory :employee do
    association :user
    association :condominium

    role { Employee::ROLES.last } # normal
    description { Faker::Job.title }


    trait :admin do
      role { Employee::ROLES.first }
    end

    trait :manager do
      role { Employee::ROLES.second }
    end
  end
end
