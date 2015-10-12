class StaticPagesController < ApplicationController

  # Show home page
  def home
    if logged_in?
      @post  = current_user.posts.build
      @feed_items = current_user.feed(nil).paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end