FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@condo.com.br" }
    document { Faker::IdNumber.brazilian_citizen_number }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number_with_country_code }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 80) }
    password { "pokpok" }
  end
end
