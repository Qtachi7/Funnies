class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_one_attached :cover
  has_many :posts, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :reacted_posts, through: :reactions, source: :post

  has_many :active_follows,  class_name: "Follow", foreign_key: "follower_id",  dependent: :destroy
  has_many :passive_follows, class_name: "Follow", foreign_key: "following_id", dependent: :destroy
  has_many :following, through: :active_follows,  source: :following
  has_many :followers, through: :passive_follows, source: :follower

  def follow(other_user)
    active_follows.create(following: other_user) unless self == other_user
  end

  def unfollow(other_user)
    active_follows.find_by(following: other_user)&.destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  validates :bio, length: { maximum: 160 }, allow_blank: true

  ALLOWED_IMAGE_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze

  validates :avatar,
    content_type: { in: ALLOWED_IMAGE_TYPES, message: "はPNG・JPG・GIF・WEBPのみ対応しています" },
    size: { less_than: 1.megabyte, message: "は1MB以内にしてください" }

  validates :cover,
    content_type: { in: ALLOWED_IMAGE_TYPES, message: "はPNG・JPG・GIF・WEBPのみ対応しています" },
    size: { less_than: 1.megabyte, message: "は1MB以内にしてください" }

  def display_name_or_email
    display_name.presence || email.split("@").first
  end
end
