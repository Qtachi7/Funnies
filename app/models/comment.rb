class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 1000 }

  scope :top_level, -> { where(parent_id: nil) }
end
