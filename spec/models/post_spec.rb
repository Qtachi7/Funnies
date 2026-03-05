require "rails_helper"

RSpec.describe Post, type: :model do
  describe "バリデーション" do
    subject { build(:post) }

    it "有効なファクトリを持つ" do
      expect(subject).to be_valid
    end

    describe "url" do
      it "必須であること" do
        subject.url = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:url]).to be_present
      end

      it "http/https URL は有効" do
        subject.url = "https://example.com/video"
        expect(subject).to be_valid
      end

      it "不正な URL は無効" do
        subject.url = "not-a-url"
        expect(subject).not_to be_valid
      end

      it "ftp:// は無効" do
        subject.url = "ftp://example.com/file"
        expect(subject).not_to be_valid
      end
    end
  end

  describe "ソース自動判別 (#detect_source)" do
    {
      "twitter"   => "https://twitter.com/user/status/123",
      "twitter"   => "https://x.com/user/status/123",
      "instagram" => "https://www.instagram.com/p/abc123/",
      "youtube"   => "https://www.youtube.com/watch?v=abc",
      "youtube"   => "https://youtu.be/abc",
      "tiktok"    => "https://www.tiktok.com/@user/video/123",
      "niconico"  => "https://www.nicovideo.jp/watch/sm12345",
      "other"     => "https://example.com/video"
    }.each do |expected_source, url|
      it "#{url} のソースは #{expected_source}" do
        post = create(:post, url: url)
        expect(post.source).to eq expected_source
      end
    end
  end

  describe "タイトル自動生成 (#extract_title_from_url)" do
    it "title 未入力の場合 URL から自動生成される" do
      post = create(:post, url: "https://example.com/video", title: nil)
      expect(post.title).to be_present
      expect(post.title).not_to include("https://")
    end

    it "title が入力済みの場合は上書きしない" do
      post = create(:post, url: "https://example.com/video", title: "手動タイトル")
      expect(post.title).to eq "手動タイトル"
    end
  end

  describe "スコープ" do
    before do
      create(:post, created_at: 2.days.ago)
      create(:post, created_at: 8.days.ago)
      create(:post, created_at: 32.days.ago)
      create(:post, created_at: 370.days.ago)
    end

    it ".today は今日の投稿のみ返す" do
      today_post = create(:post, created_at: Time.current)
      expect(Post.today).to include(today_post)
      expect(Post.today.count).to eq 1
    end

    it ".weekly は1週間以内の投稿を返す" do
      expect(Post.weekly.count).to eq 1
    end

    it ".monthly は1ヶ月以内の投稿を返す" do
      expect(Post.monthly.count).to eq 2
    end

    it ".yearly は1年以内の投稿を返す" do
      expect(Post.yearly.count).to eq 3
    end
  end

  describe "#total_reactions" do
    it "全リアクション数の合計を返す" do
      post = create(:post, funny_count: 3, laugh_count: 2, wow_count: 1)
      expect(post.total_reactions).to eq 6
    end

    it "リアクションが0件の場合は0を返す" do
      post = create(:post)
      expect(post.total_reactions).to eq 0
    end
  end

  describe "#embed_url" do
    it "YouTube の通常 URL を embed URL に変換する" do
      post = build(:post, url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      expect(post.embed_url).to eq "https://www.youtube.com/embed/dQw4w9WgXcQ"
    end

    it "youtu.be の短縮 URL を embed URL に変換する" do
      post = build(:post, url: "https://youtu.be/dQw4w9WgXcQ")
      expect(post.embed_url).to eq "https://www.youtube.com/embed/dQw4w9WgXcQ"
    end

    it "YouTube Shorts を embed URL に変換する" do
      post = build(:post, url: "https://www.youtube.com/shorts/abcdefgh")
      expect(post.embed_url).to eq "https://www.youtube.com/embed/abcdefgh"
    end

    it "ニコニコ動画を embed URL に変換する" do
      post = build(:post, url: "https://www.nicovideo.jp/watch/sm12345678")
      expect(post.embed_url).to eq "https://embed.nicovideo.jp/watch/sm12345678"
    end

    it "Twitter URL は nil を返す" do
      post = build(:post, :twitter)
      expect(post.embed_url).to be_nil
    end
  end

  describe "#embeddable?" do
    it "embed_url がある場合は true" do
      post = build(:post, :youtube)
      expect(post.embeddable?).to be true
    end

    it "embed_url がない場合は false" do
      post = build(:post, :twitter)
      expect(post.embeddable?).to be false
    end
  end
end
