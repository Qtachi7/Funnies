FactoryBot.define do
  factory :reaction do
    kind { Post::REACTION_KINDS.sample }
    association :user
    association :post

    Post::REACTION_KINDS.each do |reaction_kind|
      trait reaction_kind.to_sym do
        kind { reaction_kind }
      end
    end
  end
end
