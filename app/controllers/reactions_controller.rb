class ReactionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    @kind = params[:kind].to_s
    return unless Post::REACTION_KINDS.include?(@kind)

    reaction = current_user.reactions.find_by(post: @post, kind: @kind)
    reaction ? reaction.destroy : current_user.reactions.create!(post: @post, kind: @kind)

    @post.reload
    @user_reacted_kinds = current_user.reactions.where(post: @post).pluck(:kind).to_set

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @post }
    end
  end
end
