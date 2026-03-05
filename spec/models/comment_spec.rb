require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "バリデーション" do
    subject { build(:comment) }

    it "有効なファクトリを持つ" do
      expect(subject).to be_valid
    end

    it "body が空の場合は無効" do
      subject.body = ""
      expect(subject).not_to be_valid
      expect(subject.errors[:body]).to be_present
    end

    it "body が 1000 文字以下なら有効" do
      subject.body = "a" * 1000
      expect(subject).to be_valid
    end

    it "body が 1001 文字以上なら無効" do
      subject.body = "a" * 1001
      expect(subject).not_to be_valid
    end
  end

  describe "返信（ネスト）" do
    it "parent_id なしのコメントはトップレベル" do
      comment = create(:comment)
      expect(Comment.top_level).to include(comment)
    end

    it "parent_id ありのコメントはトップレベルに含まれない" do
      reply = create(:comment, :reply)
      expect(Comment.top_level).not_to include(reply)
    end

    it "トップレベルコメントに返信が関連付く" do
      parent  = create(:comment)
      reply   = create(:comment, parent: parent, post: parent.post, user: parent.user)
      expect(parent.replies).to include(reply)
    end
  end

  describe "カウンターキャッシュ" do
    it "コメント作成で post の comments_count が増加する" do
      post = create(:post)
      expect {
        create(:comment, post: post)
      }.to change { post.reload.comments_count }.by(1)
    end
  end
end
