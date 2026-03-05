require "rails_helper"

RSpec.describe Follow, type: :model do
  describe "バリデーション" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }

    it "有効なファクトリを持つ" do
      follow = build(:follow, follower: user_a, following: user_b)
      expect(follow).to be_valid
    end

    it "同一ペアの重複フォローは無効" do
      create(:follow, follower: user_a, following: user_b)
      duplicate = build(:follow, follower: user_a, following: user_b)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:follower_id]).to be_present
    end

    it "自分自身はフォローできない" do
      follow = build(:follow, follower: user_a, following: user_a)
      expect(follow).not_to be_valid
      expect(follow.errors[:follower_id]).to be_present
    end

    it "A→B と B→A は別のフォローとして有効" do
      create(:follow, follower: user_a, following: user_b)
      reverse = build(:follow, follower: user_b, following: user_a)
      expect(reverse).to be_valid
    end
  end

  describe "削除時のカスケード" do
    it "follower を削除するとフォローも削除される" do
      user_a = create(:user)
      user_b = create(:user)
      create(:follow, follower: user_a, following: user_b)
      expect { user_a.destroy }.to change(Follow, :count).by(-1)
    end
  end
end
