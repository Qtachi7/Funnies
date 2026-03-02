class RankingsController < ApplicationController
  VALID_PERIODS = %w[today weekly monthly yearly alltime].freeze
  VALID_KINDS   = Post::REACTION_KINDS

  def index
    @period        = VALID_PERIODS.include?(params[:period]) ? params[:period] : "today"
    @reaction_kind = VALID_KINDS.include?(params[:kind])    ? params[:kind]   : "funny"

    @posts = scoped_posts.order("#{@reaction_kind}_count DESC").limit(20)
  end

  private

  def scoped_posts
    case @period
    when "today"   then Post.today
    when "weekly"  then Post.weekly
    when "monthly" then Post.monthly
    when "yearly"  then Post.yearly
    else                Post.all
    end
  end
end
