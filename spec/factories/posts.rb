FactoryBot.define do
  factory :post do
    url   { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
    title { Faker::Lorem.sentence(word_count: 5) }
    body  { Faker::Lorem.paragraph }
    association :user

    trait :twitter do
      url { "https://twitter.com/user/status/123456789" }
    end

    trait :youtube do
      url { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
    end

    trait :tiktok do
      url { "https://www.tiktok.com/@user/video/123456789" }
    end

    trait :niconico do
      url { "https://www.nicovideo.jp/watch/sm12345678" }
    end

    trait :anonymous do
      user { nil }
    end
  end
end
