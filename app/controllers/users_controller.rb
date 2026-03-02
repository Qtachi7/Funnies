class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @tab  = params[:tab].presence_in(%w[posts reactions stats]) || "posts"

    @posts = @user.posts.order(created_at: :desc) if @tab == "posts"

    if @tab == "stats"
      @reaction_totals = Post::REACTION_KINDS.map do |kind|
        { kind: kind, count: @user.posts.sum("#{kind}_count") }
      end.sort_by { |r| -r[:count] }
      @total_reactions = @reaction_totals.sum { |r| r[:count] }
    end
  end
end
