class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  def show
    if params[:id].present?
      @user = User.find(params[:id])
    else
      redirect_to new_user_session_path and return unless user_signed_in?
      @user = current_user
    end

    @is_own_profile = user_signed_in? && current_user == @user
    @tab = params[:tab].presence_in(%w[posts reactions stats]) || "posts"

    @posts = @user.posts.order(created_at: :desc) if @tab == "posts"

    if @tab == "reactions"
      reacted_post_ids = @user.reactions.group(:post_id).order("MAX(reactions.created_at) DESC").pluck(:post_id)
      @reacted_posts = Post.where(id: reacted_post_ids).includes(:user)
                           .sort_by { |p| reacted_post_ids.index(p.id) }
      @user_reactions = @user.reactions.where(post_id: reacted_post_ids)
                             .group_by(&:post_id)
                             .transform_values { |rs| rs.map(&:kind).to_set }
    end

    if @tab == "stats"
      @reaction_totals = Post::REACTION_KINDS.map do |kind|
        { kind: kind, count: @user.posts.sum("#{kind}_count") }
      end.sort_by { |r| -r[:count] }
      @total_reactions = @reaction_totals.sum { |r| r[:count] }
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "プロフィールを更新しました"
    else
      errors = @user.errors.map { |e| [ e.attribute, e.message ] }
      @user = User.find(current_user.id)
      errors.each { |attr, msg| @user.errors.add(attr, msg) }
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :username, :bio, :avatar, :cover)
  end
end
