class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy
  helper_method :viewed

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
	  @contentPre = current_user.search_vector.split(" '").map{|c| c.split(":") }.map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  @contentPre.each do |c|
	    if current_user.bucket[c[0]] == nil
		   current_user.bucket[c[0]] = c[1]
		else
		   current_user.bucket[c[0]] = current_user.bucket[c[0]].to_i + c[1]
		end
	  end
	  current_user.update_attribute(:bucket, current_user.bucket)
	  if @micropost.created_at == nil
	    1 + "hi"
	  else
	    time = @micropost.created_at.to_f
	    @micropost.update_attribute(:rank, time)
	  end
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @contentPre = @user.search_vector.split(" '").map{|c| c.split(":") }.map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  @contentPre.each do |c|
	    if @user.bucket[c[0]] == nil
		   @user.bucket[c[0]] = c[1]
		else
		   @user.bucket[c[0]] = @user.bucket[c[0]].to_i + c[1]
		end
	  end
    @micropost.destroy
	current_user.update_attribute(:bucket, current_user.bucket)
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end
  
  def upvote(post_user)
    if @micropost.upvoteCount["total"] = nil
		@micropost.update_attribute(:upvoteCount,@micropost.upvoteCount["total"] = 1)
    else
	    @micropost.update_attribute(:upvoteCount,@micropost.upvoteCount["total"] = @micropost.upvoteCount["total"] + 1)
	end
    if @micropost.upvoteCount[current_user.email] = nil
        @micropost.update_attribute(:upvoteCount,@micropost.upvoteCount[current_user.email] = 1)
    else
	    @micropost.update_attribute(:upvoteCount,@micropost.upvoteCount[current_user.email] = @micropost.upvote[current_user.email] + 1)
    end
  end
  helper_method :upvote
  
  def viewed
    @micropost = Micropost.find(params[:id])
    post_user = User.find_by(id: @micropost.user_id)
	update = post_user.popularityCount["total"]
    if post_user.popularityCount["total"] == nil
		post_user.popularityCount["total"] = 1
		post_user.update_attribute(:popularityCount,post_user.popularityCount)
    else
	    post_user.popularityCount["total"] = post_user.popularityCount["total"].to_i + 1
	    post_user.update_attribute(:popularityCount,post_user.popularityCount)
	end
    if post_user.popularityCount[current_user.email] == nil
	    post_user.popularityCount[current_user.email] = 1
        post_user.update_attribute(:popularityCount,post_user.popularityCount)
    else
	    post_user.popularityCount[current_user.email] = post_user.popularityCount[current_user.email].to_i + 1
	    post_user.update_attribute(:popularityCount,post_user.popularityCount)
    end
	post_user.newFriends[current_user.id] = 1
	post_user.update_attribute(:newFriends,post_user.newFriends)
	redirect_to @micropost.content.split(" ")[@micropost.content.split(" ").find_index{|x| x.include? 'http'}]
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

     def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end