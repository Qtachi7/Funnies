class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_one_attached :cover
  has_many :posts, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :reacted_posts, through: :reactions, source: :post

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
