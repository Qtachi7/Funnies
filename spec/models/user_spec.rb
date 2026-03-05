require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    subject { build(:user) }

    it "有効なファクトリを持つ" do
      expect(subject).to be_valid
    end

    describe "username" do
      it "必須であること" do
        subject.username = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:username]).to be_present
      end

      it "3文字以上であること" do
        subject.username = "ab"
        expect(subject).not_to be_valid
      end

      it "20文字以下であること" do
        subject.username = "a" * 21
        expect(subject).not_to be_valid
      end

      it "半角英数字とアンダースコアのみ使用できること" do
        subject.username = "invalid-name!"
        expect(subject).not_to be_valid
      end

      it "重複不可であること" do
        create(:user, username: "taken")
        subject.username = "taken"
        expect(subject).not_to be_valid
      end

      it "大文字小文字を区別しない一意性であること" do
        create(:user, username: "TestUser")
        subject.username = "testuser"
        expect(subject).not_to be_valid
      end
    end

    describe "bio" do
      it "160文字以下であること" do
        subject.bio = "a" * 161
        expect(subject).not_to be_valid
      end

      it "160文字は有効であること" do
        subject.bio = "a" * 160
        expect(subject).to be_valid
      end

      it "空白は許可されること" do
        subject.bio = nil
        expect(subject).to be_valid
      end
    end

    describe "email" do
      it "必須であること" do
        subject.email = nil
        expect(subject).not_to be_valid
      end

      it "重複不可であること" do
        existing = create(:user)
        subject.email = existing.email
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#display_name_or_email" do
    it "display_name があれば display_name を返す" do
      user = build(:user, display_name: "表示名")
      expect(user.display_name_or_email).to eq "表示名"
    end

    it "display_name がなければ email の @ より前を返す" do
      user = build(:user, display_name: nil, email: "foo@example.com")
      expect(user.display_name_or_email).to eq "foo"
    end
  end

  describe "フォロー機能" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }

    describe "#follow" do
      it "他ユーザーをフォローできる" do
        user_a.follow(user_b)
        expect(user_a.following?(user_b)).to be true
      end

      it "自分自身はフォローできない" do
        user_a.follow(user_a)
        expect(user_a.following?(user_a)).to be false
      end
    end

    describe "#unfollow" do
      it "フォローを解除できる" do
        user_a.follow(user_b)
        user_a.unfollow(user_b)
        expect(user_a.following?(user_b)).to be false
      end
    end

    describe "#following?" do
      it "フォロー中なら true を返す" do
        create(:follow, follower: user_a, following: user_b)
        expect(user_a.following?(user_b)).to be true
      end

      it "フォローしていなければ false を返す" do
        expect(user_a.following?(user_b)).to be false
      end
    end
  end
end
