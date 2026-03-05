require "rails_helper"

RSpec.describe "Rankings", type: :request do
  before { create_list(:post, 3) }

  describe "GET /rankings (index)" do
    it "200 を返す" do
      get rankings_path
      expect(response).to have_http_status(:ok)
    end

    context "period パラメータ" do
      %w[today weekly monthly yearly alltime].each do |period|
        it "period=#{period} で 200 を返す" do
          get rankings_path, params: { period: period }
          expect(response).to have_http_status(:ok)
        end
      end

      it "不正な period でも 200 を返す（today にフォールバック）" do
        get rankings_path, params: { period: "invalid" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "kind パラメータ" do
      Post::REACTION_KINDS.each do |kind|
        it "kind=#{kind} で 200 を返す" do
          get rankings_path, params: { kind: kind }
          expect(response).to have_http_status(:ok)
        end
      end

      it "不正な kind でも 200 を返す（funny にフォールバック）" do
        get rankings_path, params: { kind: "invalid" }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
