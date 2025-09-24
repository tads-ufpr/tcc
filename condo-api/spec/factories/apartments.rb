FactoryBot.define do
  factory :apartment do
    floor { "MyString" }
    door { "MyString" }
    tower { "MyString" }
    rented { false }
    active { false }
  end
end
