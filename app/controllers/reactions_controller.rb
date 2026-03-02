class ReactionsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @kind = params[:kind].to_s

    if Post::REACTION_KINDS.include?(@kind)
      @post.increment_reaction!(@kind)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @post }
    end
  end
end
