class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  helper_method :update
  
  def index
    if params[:search]
	  @users = User.paginate(page: params[:page])
	  @users = @users.search(params[:search])
	else
	  @users = User.paginate(page: params[:page])
	end
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  def new
	@user = User.new
  end
  
  def create
    @user = User.new(user_params)
	@user.update_attribute(:location, Geocoder.search(@user.location)[0].data["formatted_address"])
	if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
	  
	  @interestPre = @user.interest.tr("?!#()'.-","").downcase.split(",")
	  @interest = @interestPre.map{|c| c.rstrip.lstrip}
      redirect_to root_url
	  users = User.all
      @interest.each do |keyword|
	    @user.findFriends(users,keyword,nil)
	  end
    else
      render 'new'
    end
  end
  
  def edit
    @contentPre = @user.search_vector.split(" '").map{|c| c.split(":") }.map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
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
		  rankTemp = friendo.active_relationships.find_by(followed_id: @user.id).rank
		  friendo.active_relationships.find_by(followed_id: @user.id).update_attribute(:rank, rankTemp+100)
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
	  @contentPre = @user.search_vector.split(" '").map{|c| c.split(":") }.map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
	  @contentPre.each do |c|
	    if @user.bucket[c[0]] == nil
		   @user.bucket[c[0]] = c[1]
		else
		   @user.bucket[c[0]] = @user.bucket[c[0]].to_i + c[1]
		end
	  end
	  @interestPre = @user.interest.tr("?!#()'.-","").downcase.split(",")
	  @interest = @interestPre.map{|c| c.rstrip.lstrip}
	  users = User.all
	  h = @user.removeFriends(@user.following)
	  @interest.each do |keyword|
	    @user.findFriends(users,keyword, h)
	  end
	  @user.update_attribute(:bucket, @user.bucket)
    else
      render 'edit'
    end
  end
  
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

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
