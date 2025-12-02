FactoryBot.define do
  factory :reservation do
    facility { nil }
    apartment { nil }
    creator { nil }
    scheduled_date { "2025-12-02" }
  end
end
