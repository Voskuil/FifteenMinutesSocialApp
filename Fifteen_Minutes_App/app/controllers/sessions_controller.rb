class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
		@interestPre = current_user.interest.tr("?!#()'.-","").downcase.split(",")
	    @interest = @interestPre.map{|c| c.rstrip.lstrip}
	    users = User.all
	    current_user.removeFriends(current_user.following)
	    @interest.each do |keyword|
	      current_user.findFriends(users,keyword,nil)
	    end
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end