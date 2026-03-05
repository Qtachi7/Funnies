FactoryBot.define do
  factory :user do
    email         { Faker::Internet.unique.email }
    password      { "password123" }
    username      { Faker::Internet.unique.username(specifier: 3..20).gsub(/[^a-zA-Z0-9_]/, "_") }
    display_name  { Faker::Name.name }
    bio           { Faker::Lorem.sentence }
  end
end
