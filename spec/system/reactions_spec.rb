require "rails_helper"

RSpec.describe "リアクションフロー", type: :system do
  let(:post_owner)   { create(:user) }
  let!(:post_record) { create(:post, user: post_owner) }
  let(:user)         { create(:user, email: "reactor@example.com", password: "password123") }

  def login_as_user(u)
    visit new_user_session_path
    fill_in "user[email]",    with: u.email
    fill_in "user[password]", with: "password123"
    click_button "ログイン"
    expect(page).to have_current_path(root_path)
  end

  # button_to の id はフォームではなくボタン要素自体に付く
  def reaction_button(post, kind)
    find("#reaction-btn-#{post.id}-#{kind}")
  end

  def reaction_count_el(post, kind)
    find("#reaction-count-#{post.id}-#{kind}")
  end

  describe "リアクションボタン" do
    context "未ログイン" do
      it "リアクションボタンをクリックするとログインへリダイレクト" do
        visit post_path(post_record)
        reaction_button(post_record, "funny").click
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { login_as_user(user) }

      it "funny リアクションをクリックするとカウントが増える" do
        visit post_path(post_record)

        reaction_button(post_record, "funny").click

        expect(reaction_count_el(post_record, "funny")).to have_text("1")
        expect(post_record.reload.funny_count).to eq(1)
      end

      it "同じリアクションを再度クリックするとカウントが戻る（トグル OFF）" do
        visit post_path(post_record)

        reaction_button(post_record, "funny").click
        expect(reaction_count_el(post_record, "funny")).to have_text("1")

        reaction_button(post_record, "funny").click
        expect(reaction_count_el(post_record, "funny")).to have_text("0")
        expect(post_record.reload.funny_count).to eq(0)
      end

      it "複数の種類のリアクションが付けられる" do
        visit post_path(post_record)

        reaction_button(post_record, "funny").click
        expect(reaction_count_el(post_record, "funny")).to have_text("1")

        reaction_button(post_record, "laugh").click
        expect(reaction_count_el(post_record, "laugh")).to have_text("1")

        expect(post_record.reload.funny_count).to eq(1)
        expect(post_record.reload.laugh_count).to eq(1)
      end

      it "Turbo Stream でページリロードなしにカウントが更新される" do
        visit post_path(post_record)
        initial_url = page.current_url

        reaction_button(post_record, "funny").click
        expect(reaction_count_el(post_record, "funny")).to have_text("1")

        # URL が変わっていない = フルリロードなし
        expect(page.current_url).to eq(initial_url)
      end
    end
  end

  describe "ランキングとリアクションの連動" do
    it "リアクションが多い投稿がランキング上位に表示される" do
      popular_post = create(:post, body: "超人気コンテンツ", funny_count: 100, user: post_owner)
      normal_post  = create(:post, body: "普通のコンテンツ", funny_count: 1,   user: post_owner)

      visit rankings_path(period: "alltime", kind: "funny")

      popular_index = page.body.index("超人気コンテンツ")
      normal_index  = page.body.index("普通のコンテンツ")

      expect(popular_index).to be < normal_index
    end
  end
end
