require "rails_helper"

RSpec.describe Reaction, type: :model do
  describe "バリデーション" do
    subject { build(:reaction) }

    it "有効なファクトリを持つ" do
      expect(subject).to be_valid
    end

    it "kind は REACTION_KINDS 内の値である必要がある" do
      subject.kind = "invalid_kind"
      expect(subject).not_to be_valid
      expect(subject.errors[:kind]).to be_present
    end

    it "同一ユーザー・同一投稿・同一 kind は重複不可" do
      reaction = create(:reaction, :funny)
      duplicate = build(:reaction, :funny, user: reaction.user, post: reaction.post)
      expect(duplicate).not_to be_valid
    end

    it "同一ユーザー・同一投稿でも kind が異なれば有効" do
      reaction = create(:reaction, :funny)
      different_kind = build(:reaction, :laugh, user: reaction.user, post: reaction.post)
      expect(different_kind).to be_valid
    end

    Post::REACTION_KINDS.each do |kind|
      it "kind=#{kind} は有効" do
        subject.kind = kind
        expect(subject).to be_valid
      end
    end
  end

  describe "カウントの自動更新" do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    it "リアクション作成時に対応する count がインクリメントされる" do
      expect {
        create(:reaction, :funny, user: user, post: post)
      }.to change { post.reload.funny_count }.by(1)
    end

    it "リアクション削除時に対応する count がデクリメントされる" do
      reaction = create(:reaction, :funny, user: user, post: post)
      expect {
        reaction.destroy
      }.to change { post.reload.funny_count }.by(-1)
    end
  end
end
