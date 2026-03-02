require "net/http"
require "json"

module PostsHelper
  # Twitter oEmbed API からツイートの埋め込みHTMLを取得してキャッシュする。
  # 取得に失敗した場合は nil を返す（ビュー側でフォールバック表示）。
  def twitter_oembed_html(post)
    Rails.cache.fetch("twitter_oembed/#{post.id}", expires_in: 24.hours) do
      uri = URI("https://publish.twitter.com/oembed?url=#{CGI.escape(post.url)}&dnt=1&lang=ja")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 2
      http.read_timeout = 3
      resp = http.get(uri.request_uri)
      JSON.parse(resp.body)["html"].html_safe if resp.is_a?(Net::HTTPSuccess)
    rescue StandardError
      nil
    end
  end
end
