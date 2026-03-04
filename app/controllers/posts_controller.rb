class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @posts = Post.order(created_at: :desc)
    @post  = Post.new
    @user_reacted_kinds = if current_user
      current_user.reactions.where(post: @posts)
        .group_by(&:post_id)
        .transform_values { |rs| rs.map(&:kind).to_set }
    else
      {}
    end
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.top_level.includes(:user, replies: :user).order(created_at: :asc)
    @user_reacted_kinds = current_user&.reactions&.where(post: @post)
                                       &.pluck(:kind)&.to_set || Set.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to root_path, notice: "投稿しました！"
    else
      @posts = Post.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.expect(post: [:url, :title, :body])
  end
end
