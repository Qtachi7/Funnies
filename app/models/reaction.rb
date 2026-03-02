class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :kind, inclusion: { in: Post::REACTION_KINDS }
  validates :user_id, uniqueness: { scope: [:post_id, :kind] }

  after_create_commit  -> { post.increment!("#{kind}_count") }
  after_destroy_commit -> { post.decrement!("#{kind}_count") }
end
