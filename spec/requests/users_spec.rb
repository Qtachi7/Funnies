require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/:id (show)" do
    it "200 を返す" do
      get user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "存在しないユーザーは 404" do
      get user_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end

    context "tab パラメータ" do
      before { sign_in user }

      %w[posts reactions stats].each do |tab|
        it "tab=#{tab} で 200 を返す" do
          get user_path(user), params: { tab: tab }
          expect(response).to have_http_status(:ok)
        end
      end

      it "不正な tab は posts タブにフォールバック" do
        get user_path(user), params: { tab: "invalid" }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /profile/edit (edit)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        get edit_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in user }

      it "200 を返す" do
        get edit_profile_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /profile (update)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        patch profile_path, params: { user: { display_name: "新しい名前" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in user }

      it "display_name を更新してプロフィールへリダイレクト" do
        patch profile_path, params: { user: { display_name: "更新後の名前" } }
        expect(response).to redirect_to(profile_path)
        expect(user.reload.display_name).to eq "更新後の名前"
      end

      it "username の形式エラーは 422 を返す" do
        patch profile_path, params: { user: { username: "invalid name!" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "bio が 160 文字を超えると 422 を返す" do
        patch profile_path, params: { user: { bio: "a" * 161 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
