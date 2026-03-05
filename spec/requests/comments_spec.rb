require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:user)        { create(:user) }
  let(:post_record) { create(:post) }

  describe "POST /posts/:post_id/comments (create)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        post post_comments_path(post_record), params: { comment: { body: "テスト" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in user }

      it "コメントを作成して投稿詳細へリダイレクト" do
        expect {
          post post_comments_path(post_record), params: { comment: { body: "面白い！" } }
        }.to change(Comment, :count).by(1)
        expect(response).to redirect_to(post_path(post_record, anchor: "comments"))
      end

      it "body 空の場合は 422 を返す" do
        post post_comments_path(post_record), params: { comment: { body: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "返信コメントを作成できる" do
        parent = create(:comment, post: post_record, user: user)
        expect {
          post post_comments_path(post_record), params: {
            comment: { body: "返信です", parent_id: parent.id }
          }
        }.to change(Comment, :count).by(1)
        expect(Comment.last.parent).to eq parent
      end
    end
  end

  describe "DELETE /posts/:post_id/comments/:id (destroy)" do
    let!(:comment) { create(:comment, post: post_record, user: user) }

    context "未ログイン" do
      it "ログインページへリダイレクト" do
        delete post_comment_path(post_record, comment)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "コメント投稿者本人" do
      before { sign_in user }

      it "コメントを削除して投稿詳細へリダイレクト" do
        expect {
          delete post_comment_path(post_record, comment)
        }.to change(Comment, :count).by(-1)
        expect(response).to redirect_to(post_path(post_record, anchor: "comments"))
      end
    end

    context "他ユーザー" do
      before { sign_in create(:user) }

      it "削除されずリダイレクトされる" do
        expect {
          delete post_comment_path(post_record, comment)
        }.not_to change(Comment, :count)
      end
    end
  end
end
