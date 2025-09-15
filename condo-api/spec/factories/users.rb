FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "email#{n}@condo.com.br" }
    document { Faker::IdNumber.brazilian_citizen_number }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 80) }
  end
end
