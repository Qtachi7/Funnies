class Post < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reactions, dependent: :destroy

  REACTION_KINDS = %w[funny laugh cry wow cool cute surprised].freeze

  SOURCE_PATTERNS = {
    "twitter"   => /twitter\.com|x\.com/i,
    "instagram" => /instagram\.com/i,
    "youtube"   => /youtube\.com|youtu\.be/i,
    "tiktok"    => /tiktok\.com/i,
    "niconico"  => /nicovideo\.jp|nico\.ms/i
  }.freeze

  SOURCE_NAMES = {
    "twitter"   => "X (Twitter)",
    "instagram" => "Instagram",
    "youtube"   => "YouTube",
    "tiktok"    => "TikTok",
    "niconico"  => "ニコニコ動画",
    "other"     => "その他"
  }.freeze

  SOURCE_ICONS = {
    "twitter"   => "𝕏",
    "instagram" => "📷",
    "youtube"   => "▶",
    "tiktok"    => "🎵",
    "niconico"  => "ニコ",
    "other"     => "🔗"
  }.freeze

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "は有効なURLを入力してください" }

  before_save :detect_source
  before_save :extract_title_from_url

  scope :today,   -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :weekly,  -> { where(created_at: 1.week.ago..Time.current) }
  scope :monthly, -> { where(created_at: 1.month.ago..Time.current) }
  scope :yearly,  -> { where(created_at: 1.year.ago..Time.current) }

  def source_name
    SOURCE_NAMES[source] || source.to_s.capitalize
  end

  def source_icon
    SOURCE_ICONS[source] || "🔗"
  end

  def total_reactions
    REACTION_KINDS.sum { |kind| send("#{kind}_count") }
  end

  def reaction_count(kind)
    send("#{kind}_count")
  end

  def author_name
    user&.display_name_or_email || "匿名"
  end

  # iframe で埋め込める URL を返す（YouTube / NicoNico のみ）
  def embed_url
    case source
    when "youtube"  then youtube_embed_url
    when "niconico" then niconico_embed_url
    end
  end

  def embeddable?
    embed_url.present?
  end

  private

  def youtube_embed_url
    video_id = nil
    [
      %r{youtu\.be/([^?&/\s]+)},           # https://youtu.be/VIDEO_ID
      %r{[?&]v=([^&\s]+)},                  # ?v=VIDEO_ID or &v=VIDEO_ID
      %r{youtube\.com/embed/([^?&/\s]+)},   # already embed URL
      %r{youtube\.com/shorts/([^?&/\s]+)},  # Shorts
    ].each do |pattern|
      if url.match(pattern)
        video_id = $1
        break
      end
    end
    video_id ? "https://www.youtube.com/embed/#{video_id}" : nil
  end

  def niconico_embed_url
    if url.match(%r{nicovideo\.jp/watch/([a-z]{2}\d+)})
      "https://embed.nicovideo.jp/watch/#{$1}"
    end
  end

  def detect_source
    SOURCE_PATTERNS.each do |src, pattern|
      if url.match?(pattern)
        self.source = src
        return
      end
    end
    self.source ||= "other"
  end

  def extract_title_from_url
    return if title.present?
    self.title = url.gsub(/https?:\/\//, "").truncate(60)
  end
end
