require "rails_helper"

RSpec.describe "投稿フロー", type: :system do
  let(:user) { create(:user, email: "poster@example.com", password: "password123") }

  def login_as_user(u)
    visit new_user_session_path
    fill_in "user[email]",    with: u.email
    fill_in "user[password]", with: "password123"
    click_button "ログイン"
    expect(page).to have_current_path(root_path)
  end

  describe "投稿一覧" do
    it "投稿がない場合もページが表示される" do
      visit root_path
      expect(page).to have_content("まだ投稿がありません")
    end

    it "投稿がある場合にコンテンツが表示される" do
      create(:post, body: "これは面白い動画です！", user: user)
      visit root_path
      expect(page).to have_content("これは面白い動画です！")
    end
  end

  describe "投稿詳細" do
    it "投稿の詳細が表示される" do
      post_record = create(:post, body: "テスト投稿の内容です", user: user)
      visit post_path(post_record)
      expect(page).to have_content("テスト投稿の内容です")
    end
  end

  describe "投稿作成" do
    before { login_as_user(user) }

    it "有効な URL で投稿が作成される" do
      visit root_path

      # id セレクタで確実に取得
      fill_in "post_url", with: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      click_button "投稿する"

      expect(page).to have_content("投稿しました")
    end

    it "無効な URL（http/https 以外）では投稿が作成されない" do
      visit root_path

      # ftp:// はHTML5 type=url を通過するが Rails バリデーションで弾かれる
      fill_in "post_url", with: "ftp://example.com/video"
      click_button "投稿する"

      expect(page).to have_content("有効なURL")
    end
  end

  describe "投稿削除" do
    let!(:post_record) { create(:post, body: "削除するコンテンツ", user: user) }

    before { login_as_user(user) }

    it "自分の投稿を削除できる" do
      visit root_path
      expect(page).to have_content("削除するコンテンツ")

      # Stimulus が不要な方法でケバブメニューを開く
      page.execute_script(
        "document.querySelector('[data-kebab-target=\"menu\"]').classList.remove('hidden')"
      )

      accept_confirm do
        click_button "削除"
      end

      expect(page).not_to have_content("削除するコンテンツ")
    end
  end

  describe "コメント投稿" do
    let!(:post_record) { create(:post, user: user) }

    before { login_as_user(user) }

    it "コメントを投稿できる" do
      visit post_path(post_record)

      fill_in "comment_body", with: "これは面白い！"
      click_button "送信"

      expect(page).to have_content("これは面白い！")
    end

    it "空のコメントは送信されない" do
      visit post_path(post_record)

      expect {
        fill_in "comment_body", with: ""
        click_button "送信"
        # 422 後の再描画を待つ
        expect(page).to have_css("textarea#comment_body")
      }.not_to change(Comment, :count)
    end
  end

  describe "ランキングページ" do
    before { create_list(:post, 3, user: user) }

    it "ランキングページが表示される" do
      visit rankings_path
      expect(page).to have_content("ランキング")
    end

    it "期間タブが表示される" do
      visit rankings_path
      expect(page).to have_content("今日")
      expect(page).to have_content("週間")
      expect(page).to have_content("月間")
    end
  end
end
