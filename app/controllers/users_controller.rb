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
