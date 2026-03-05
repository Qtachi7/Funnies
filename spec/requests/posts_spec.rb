require "rails_helper"

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let!(:post_record) { create(:post, user: user) }

  describe "GET /posts (index)" do
    it "200 を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /posts/:id (show)" do
    it "200 を返す" do
      get post_path(post_record)
      expect(response).to have_http_status(:ok)
    end

    it "存在しない投稿は 404" do
      get post_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /posts (create)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        post posts_path, params: { post: { url: "https://example.com" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in user }

      it "有効な URL で投稿作成しルートへリダイレクト" do
        expect {
          post posts_path, params: { post: { url: "https://www.youtube.com/watch?v=abc" } }
        }.to change(Post, :count).by(1)
        expect(response).to redirect_to(root_path)
      end

      it "無効な URL では 422 を返す" do
        post posts_path, params: { post: { url: "not-a-url" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /posts/:id (destroy)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        delete post_path(post_record)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "投稿者本人" do
      before { sign_in user }

      it "投稿を削除してルートへリダイレクト" do
        expect {
          delete post_path(post_record)
        }.to change(Post, :count).by(-1)
        expect(response).to redirect_to(root_path)
      end
    end

    context "他ユーザー" do
      before { sign_in create(:user) }

      it "削除できずルートへリダイレクト" do
        expect {
          delete post_path(post_record)
        }.not_to change(Post, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
