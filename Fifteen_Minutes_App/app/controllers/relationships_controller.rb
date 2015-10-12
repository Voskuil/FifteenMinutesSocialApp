class RelationshipsController < ApplicationController
  #include PgSearch
  #pg_search_scope :psearch, against: [:description],
  #  using: {tsearch: {dictionary: "english"}},
  #	associated_against: {posts: :content}
  before_action :logged_in_user

  # Create new relationship
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  # Delete relationship
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end