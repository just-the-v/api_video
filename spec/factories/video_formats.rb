FactoryBot.define do
  factory :video_format do
    video { create(:video) }
    source { "MyString" }
    format { "MyString" }
    file { "MyString" }
  end
end
