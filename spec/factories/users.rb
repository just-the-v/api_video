# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    pseudo  { Faker::Internet.username }
    email { Faker::Internet.email }
    password { 'password' }
  end
end
