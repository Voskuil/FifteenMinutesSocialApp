class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  helper_method :update
  
  # Page to list all users, allowing pagination and search
  def index
    if params[:search]
	  @users = User.paginate(page: params[:page])
	  @users = @users.search(params[:search])
	else
	  @users = User.paginate(page: params[:page])
	end
  end
  
  # Page to show user's profile and paginate respective posts
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.paginate(page: params[:page])
  end
  
  # Delete user
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  # New user from signup
  def new
	@user = User.new
  end
  
  # Generates user with given parameters, uses geocoder to find the given
  # location, and searches through interests to find users to follow.
  def create
    @user = User.new(user_params)
	@user.update_attribute(:location, 
	      Geocoder.search(@user.location)[0].data["formatted_address"])
	if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
	  
	  interests = @user.interest.tr("?!#()'.-","").downcase.split(",")
	  interests = interests.map{|c| c.rstrip.lstrip}
      redirect_to root_url
	  users = User.all
      interests.each do |keyword|
	    @user.findFriends(users,keyword,nil)
	  end
    else
      render 'new'
    end
  end
  
  # Page to edit user
  def edit
    @contentPre = @user.search_vector.split(" '").map{|c| c.split(":") }.
	                    map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  @contentPre.each do |c|
	    if @user.bucket[c[0]] == nil
		   @user.bucket[c[0]] = c[1]
		else
		   @user.bucket[c[0]] = @user.bucket[c[0]].to_i + c[1]
		end
	  end
	@user.update_attribute(:bucket, @user.bucket)
	@user = User.find(params[:id])
  end

  # Update user with new parameters and also;
  # 1. If there are newFriends who have shown interest, re-initialize training
  #    data and find liklihood_and_priors.
  # 2. Add user's updated search_vector into his respective bucket column
  # 3. Re-find users to follow with updated interests.
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
	  users = @user.followers
	  @user.peerBucketAdd(users)
	  if @user.trainData == {} and @user.newFriends != {}
	    @user.newFriends.each do |friend,count|
	      #@user.initializer(friend)
		  #@user.liklihood_and_priors
		  friendo = User.find_by(id: friend)
		  rankTemp = friendo.active_relationships.
		                     find_by(followed_id: @user.id).rank
		  friendo.active_relationships.find_by(followed_id: @user.id).
									   update_attribute(:rank, rankTemp+100)
		end
	  elsif @user.trainData != {} and @user.newFriends != {}
	    @user.newFriends.select{|name| @user.trainData["friends"]["name"][name] != nil}.each do |name|
	      user = User.find_by(email: name)
		  @user.initializer(name)
		  @user.liklihood_and_priors
	    end
	  else
	  end
	  @user.update_attribute(:newFriends, {})
	  content = @user.search_vector.split(" '").map{|c| c.split(":") }.
	                                map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  content.each do |c|
	    if @user.bucket[c[0]] == nil
		   @user.bucket[c[0]] = c[1]
		else
		   @user.bucket[c[0]] = @user.bucket[c[0]].to_i + c[1]
		end
	  end
	  interests = @user.interest.tr("?!#()'.-","").downcase.split(",")
	  interests = interests.map{|c| c.rstrip.lstrip}
	  users = User.all
	  h = @user.removeFriends(@user.following)
	  interests.each do |keyword|
	    @user.findFriends(users,keyword, h)
	  end
	  @user.update_attribute(:bucket, @user.bucket)
    else
      render 'edit'
    end
  end
  
  # Page to show users the current user is following
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  # Page to show users that are following the current user
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    # Define user-given parameters
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation,
								   :description, :interest,
								   :picture, :location)
    end
	
	def logged_in_user
      unless logged_in?
	    store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
	
	def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
	
	def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
