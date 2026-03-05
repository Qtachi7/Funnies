require "rails_helper"

RSpec.describe "Follows", type: :request do
  let(:current_user) { create(:user) }
  let(:target_user)  { create(:user) }

  describe "POST /users/:user_id/follow (create)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        post user_follow_path(target_user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in current_user }

      it "フォローを作成する" do
        expect {
          post user_follow_path(target_user)
        }.to change(Follow, :count).by(1)
      end

      it "フォロー済みのユーザーを再度フォローしても増えない" do
        create(:follow, follower: current_user, following: target_user)
        expect {
          post user_follow_path(target_user)
        }.not_to change(Follow, :count)
      end
    end
  end

  describe "DELETE /users/:user_id/follow (destroy)" do
    let!(:follow) { create(:follow, follower: current_user, following: target_user) }

    context "未ログイン" do
      it "ログインページへリダイレクト" do
        delete user_follow_path(target_user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in current_user }

      it "フォローを削除する" do
        expect {
          delete user_follow_path(target_user)
        }.to change(Follow, :count).by(-1)
      end
    end
  end
end
