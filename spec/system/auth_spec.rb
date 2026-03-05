require "rails_helper"

RSpec.describe "認証フロー", type: :system do
  describe "ユーザー登録" do
    it "有効な情報で登録してホームへ遷移する" do
      visit new_user_registration_path

      fill_in "user[email]",                 with: "newuser@example.com"
      fill_in "user[username]",              with: "new_user123"
      fill_in "user[password]",              with: "password123"
      fill_in "user[password_confirmation]", with: "password123"
      click_button "アカウント作成"

      expect(page).to have_current_path(root_path)
    end

    it "メールアドレス重複で登録エラーが表示される" do
      existing = create(:user)
      visit new_user_registration_path

      fill_in "user[email]",                 with: existing.email
      fill_in "user[username]",              with: "unique_name_xyz"
      fill_in "user[password]",              with: "password123"
      fill_in "user[password_confirmation]", with: "password123"
      click_button "アカウント作成"

      expect(page).to have_content("すでに存在します")
    end

    it "ユーザー名に記号を使うと登録エラーが表示される" do
      visit new_user_registration_path

      fill_in "user[email]",                 with: "test@example.com"
      fill_in "user[username]",              with: "invalid name!"
      fill_in "user[password]",              with: "password123"
      fill_in "user[password_confirmation]", with: "password123"
      click_button "アカウント作成"

      expect(page).to have_content("半角英数字")
    end
  end

  describe "ログイン" do
    let(:user) { create(:user, email: "login@example.com", password: "password123") }

    it "正しい認証情報でログインしてホームへ遷移する" do
      visit new_user_session_path

      fill_in "user[email]",    with: user.email
      fill_in "user[password]", with: "password123"
      click_button "ログイン"

      expect(page).to have_current_path(root_path)
    end

    it "誤ったパスワードでログインエラーが表示される" do
      visit new_user_session_path

      fill_in "user[email]",    with: user.email
      fill_in "user[password]", with: "wrongpassword"
      click_button "ログイン"

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("パスワードが違います")
    end
  end

  describe "ログアウト" do
    it "ログアウト後にホームへ遷移する" do
      user = create(:user, password: "password123")
      visit new_user_session_path
      fill_in "user[email]",    with: user.email
      fill_in "user[password]", with: "password123"
      click_button "ログイン"

      first("button", text: "ログアウト").click

      expect(page).to have_current_path(root_path)
      expect(page).not_to have_button("ログアウト")
    end
  end
end
