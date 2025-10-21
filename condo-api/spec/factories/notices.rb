FactoryBot.define do
  factory :notice do
    apartment { nil }
    creator { nil }
    notice_type { 1 }
    status { 1 }
    description { "MyText" }
    title { "MyText" }
    type_info { "MyText" }
  end
end
