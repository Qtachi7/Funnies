class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def destroy
    @comment = @post.comments.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
    end
    redirect_to post_path(@post, anchor: "comments")
  end

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to post_path(@post, anchor: "comments")
    else
      @comments = @post.comments.top_level.includes(:user, replies: :user).order(created_at: :asc)
      render "posts/show", status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
