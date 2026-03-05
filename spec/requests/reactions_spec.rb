require "rails_helper"

RSpec.describe "Reactions", type: :request do
  let(:user)        { create(:user) }
  let(:post_record) { create(:post) }

  describe "POST /posts/:post_id/reactions (create)" do
    context "未ログイン" do
      it "ログインページへリダイレクト" do
        post post_reactions_path(post_record), params: { kind: "funny" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済み" do
      before { sign_in user }

      it "リアクションを作成する" do
        expect {
          post post_reactions_path(post_record), params: { kind: "funny" }
        }.to change(Reaction, :count).by(1)
      end

      it "post の funny_count がインクリメントされる" do
        expect {
          post post_reactions_path(post_record), params: { kind: "funny" }
        }.to change { post_record.reload.funny_count }.by(1)
      end

      it "同じリアクションを再度送るとトグル OFF（削除）される" do
        create(:reaction, :funny, user: user, post: post_record)
        expect {
          post post_reactions_path(post_record), params: { kind: "funny" }
        }.to change(Reaction, :count).by(-1)
      end

      it "不正な kind は無視される" do
        expect {
          post post_reactions_path(post_record), params: { kind: "invalid" }
        }.not_to change(Reaction, :count)
      end

      Post::REACTION_KINDS.each do |kind|
        it "kind=#{kind} のリアクションが作成できる" do
          expect {
            post post_reactions_path(post_record), params: { kind: kind }
          }.to change(Reaction, :count).by(1)
        end
      end
    end
  end
end
