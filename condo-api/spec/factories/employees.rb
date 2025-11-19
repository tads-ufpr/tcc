FactoryBot.define do
  factory :employee do
    association :user
    association :condominium

    role { :collaborator }
    description { Faker::Job.title }

    trait :admin do
      role { :admin }
    end

    trait :collaborator do
      role { :collaborator }
    end
  end
end
