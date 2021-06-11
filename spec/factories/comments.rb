FactoryBot.define do
  factory :comment do
    user { create(:user) }
    video { create(:video, user: user) }
    body { "MyText" }
  end
end
