class PostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy
  helper_method :viewed

  # Create a post with given parameters associated with a user, and;
  # 1. Moves content in search vector to user's bucket
  # 2. Give an initial ranking to the post given by the time of the post
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Post created!"
	  content = current_user.search_vector.split(" '").map{|c| c.split(":") }.
	                         map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  content.each do |c|
	    if current_user.bucket[c[0]] == nil
		   current_user.bucket[c[0]] = c[1]
		else
		   current_user.bucket[c[0]] = current_user.bucket[c[0]].to_i + c[1]
		end
	  end
	  current_user.update_attribute(:bucket, current_user.bucket)
	  time = @post.created_at.to_f
	  @post.update_attribute(:rank, time)
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  # Deletes posts and removes content from bucket
  def destroy
    content = @user.search_vector.split(" '").map{|c| c.split(":") }.
	                map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  content.each do |c|
	    if @user.bucket[c[0]] == nil
		   @user.bucket[c[0]] = c[1]
		else
		   @user.bucket[c[0]] = @user.bucket[c[0]].to_i + c[1]
		end
	  end
    @post.destroy
	current_user.update_attribute(:bucket, current_user.bucket)
    flash[:success] = "Post deleted"
    redirect_to request.referrer || root_url
  end
  
  # Update upvote count of the post
  def upvote(post_user)
    if @post.upvoteCount["total"] = nil
		@post.update_attribute(:upvoteCount,@post.upvoteCount["total"] = 1)
    else
	    @post.update_attribute(:upvoteCount,@post.upvoteCount["total"] = 
		                        @post.upvoteCount["total"] + 1)
	end
    if @post.upvoteCount[current_user.email] = nil
        @post.update_attribute(:upvoteCount,
		                        @post.upvoteCount[current_user.email] = 1)
    else
	    @post.update_attribute(:upvoteCount,
		                       @post.upvoteCount[current_user.email] = 
							   @post.upvote[current_user.email] + 1)
    end
  end
  helper_method :upvote
  
  # Update post's user's popularityCount and newFriends if another user views
  # his content by clicking a given link.
  def viewed
    @post = Post.find(params[:id])
    post_user = User.find_by(id: @post.user_id)
	update = post_user.popularityCount["total"]
    if post_user.popularityCount["total"] == nil
		post_user.popularityCount["total"] = 1
		post_user.update_attribute(:popularityCount,post_user.popularityCount)
    else
	    post_user.popularityCount["total"] = 
		          post_user.popularityCount["total"].to_i + 1
	    post_user.update_attribute(:popularityCount,post_user.popularityCount)
	end
    if post_user.popularityCount[current_user.email] == nil
	    post_user.popularityCount[current_user.email] = 1
        post_user.update_attribute(:popularityCount,post_user.popularityCount)
    else
	    post_user.popularityCount[current_user.email] = 
		          post_user.popularityCount[current_user.email].to_i + 1
	    post_user.update_attribute(:popularityCount,post_user.popularityCount)
    end
	post_user.newFriends[current_user.id] = 1
	post_user.update_attribute(:newFriends,post_user.newFriends)
	redirect_to @post.content.split(" ")[@post.content.split(" ").
	                                      find_index{|x| x.include? 'http'}]
  end

  private

    def post_params
      params.require(:post).permit(:content, :picture)
    end

     def correct_user
      @post = current_user.posts.find_by(id: params[:id])
      redirect_to root_url if @post.nil?
    end
end