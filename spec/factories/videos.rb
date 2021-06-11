FactoryBot.define do
  factory :video do
    user { create(:user) }
    views { 0 }
    name { Faker::Lorem.sentence }
    enabled { false }
    source { nil }
    duration { 0 }
  end
end
