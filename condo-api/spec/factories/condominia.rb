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
  end
end
