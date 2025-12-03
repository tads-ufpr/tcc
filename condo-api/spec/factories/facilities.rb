FactoryBot.define do
  factory :facility do
    name { Faker::FunnyName.name }
    description { Faker::FunnyName.two_word_name }
    tax { 200 }
    schedulable { true }

    association :condominium
  end
end
