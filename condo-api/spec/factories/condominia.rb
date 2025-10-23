FactoryBot.define do
  factory :condominium do
    name { "Condomínio #{Faker::Name.name}" }
    city { Faker::Address.city }
    state { Faker::Address.state }
    address { Faker::Address.street_name }
    number { Faker::Address.building_number }
    zipcode { Faker::Address.zip_code }
    neighborhood { Faker::Address.community }

    trait :with_staff do
      after(:create) do |condominium, evaluator|
        create(:employee, :admin, condominium: condominium)
      end
    end

    trait :with_apartments do
      after(:create) do |condominium, evaluator|
        create(:apartment, condominium: condominium)
      end
    end

    trait :with_residents do
      transient do
        residents_count { 1 }
      end

      after(:create) do |condominium, evaluator|
        evaluator.residents_count.times do
          apartment = create(:apartment, condominium: condominium)
          create(:resident, apartment: apartment)
        end
      end
    end
  end
end
