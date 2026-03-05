FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }
    association :user
    association :post

    trait :reply do
      association :parent, factory: :comment
    end
  end
end
