class User < ActiveRecord::Base
  include PgSearch
  require 'matrix'
  acts_as_messageable
  mount_uploader :picture, PictureUploader
  validate  :picture_size
  has_many :posts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  pg_search_scope :psearch, against: [:name, :description, :interest],
        associated_against: {posts: :content},
        using: {tsearch: {dictionary: "english"}}
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  scope :enabled, -> {
        joins("INNER JOIN profiles as p01 ON p01.id = users.posts_id").
		where("po1.enabled IS true")
}
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
					uniqueness: { case_sensitive: false }
  validates :description, presence: true, length: {maximum: 1000}
  VALID_TAG_REGEX = /\A(([^,],?)+)\z/i
  validates :interest, presence: true, length: {maximum: 255},
                       format: { with: VALID_TAG_REGEX}
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  
  # Returns the hash of string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Generate a token
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Generate a remember token
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Search using pg_search_scope from the pg_search gem
  def self.search(query)
    #rank = ts_rank(to_tsvector(name),plainto_tsquery("#{sanitize(query)}")) +
	#       ts_rank(to_tsvector(name),plainto_tsquery("#{sanitize(query)}"))
	if query.present?
	#	where("name @@ :q OR description @@ :q", q: query).order("#{rank} desc")
	    psearch(query)
	else
		scoped
	end
  end
  
  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Activates account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # Returns a user's status feed in order by rank.
  def feed(sieve)
    if sieve != nil
      following_ids = "SELECT followed_id FROM relationships
                       WHERE  follower_id = :user_id"
	  Post.joins(:user).where("user_id IN (#{following_ids})
                       OR user_id = :user_id", user_id: id).
					   order("CAST(users.rank -> CAST(#{id} as TEXT) 
					          as NUMERIC) + CAST(posts.rank as NUMERIC)").
					   reverse_order
	else
	  following_ids = "SELECT followed_id FROM relationships
                       WHERE  follower_id = :user_id"
	  Post.joins(:user).where("user_id IN (#{following_ids})
                       OR user_id = :user_id", user_id: id).
					   order("CAST(users.rank -> CAST(#{id} as TEXT)
					   as NUMERIC) + CAST(posts.rank as NUMERIC)").
					   reverse_order
	end
  end

  # Follows a user, marks user in special if the user was manually followed
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
	#active_relationships.update_attribute(:rank, 0.0)
	if special.empty?
	  update_attribute(:special, {0 => {other_user.id => true}})
	elsif special['0'] == nil
	  update_attribute(:special, special['0'] = {other_user.id => true})
	else
	  update_attribute(:special, special['0'][other_user.id] = true)
	end
  end

  # Unfollows a user, marks user in special if the user was manually unfollowed
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
	if special.empty?
	  update_attribute(:special, {1 => {other_user.id => true}})
	elsif special[1] == nil
	  update_attribute(:special, special['1'] = {other_user.id => true})
	else
	  update_attribute(:special, special['1'][other_user.id] = true)
	end
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end
  
  
  # Finds and follows all users that share the query and checks
  # if the user's rank needs to be adjusted.
  def findFriends(users,query,h)
    users.each do |user|
      if query.split(" ").map{|c| user.bucket[c] != nil}.
	                      inject{|all,exists| all and exists} and 
		(special.empty? or special['1'] == nil or special['1'][user.id] == nil)
	    if active_relationships.find_by(followed_id: user.id) != nil
		  rankTemp = active_relationships.find_by(followed_id: user.id).rank
		  active_relationships.find_by(followed_id: user.id).destroy
		else
		  if h == nil or h[user.id] == nil
		    rankTemp = 0.0
		  else
		    rankTemp = h[user.id]
		  end
		end
		active_relationships.create(followed_id: user.id)
		active_relationships.find_by(followed_id: user.id).
		                     update_attribute(:rank, rankTemp)
		newFriend = User.find_by(id: user.id)
		rank[id] = active_relationships.find_by(followed_id: user.id).rank
		user.update_attribute(:rank, rank)
		if trainData != {}
		   classify(user)
		end
		if active_relationships.find_by(followed_id: user.id).common == nil
		   active_relationships.find_by(followed_id: user.id).
		                        update_attribute(:common, "#" + query)
		else
		   active_relationships.find_by(followed_id: user.id).
		                        update_attribute(:common, 
								                  active_relationships.
												  find_by(followed_id: user.id).
												  common + "#" + query + " ")
		end
	  end
	end
  end
  
  # Merge all users' buckets into the current user's peerBucket
  def peerBucketAdd(users)
    users.each do |user|
      peerBucket.merge!(user.bucket)
    end
	update_attribute(:peerBucket, peerBucket)
  end
  
  # Unfollows all users following user except those
  # otherwise mentioned in special
  def removeFriends(users)
    h = {}
    users.each do |user|
	  if special.empty? or special['0'] == nil or special['0'][user.id] == nil
	    rank = active_relationships.find_by(followed_id: user.id).rank
		h[user.id] = rank
	    active_relationships.find_by(followed_id: user.id).destroy
	  end
	end
	h
  end
  
  # Defines name to be used for mailboxer
  def namer
    name
  end

  # Defines email to be used in mailboxer
  def mailboxer_email(object)
    email
  end
  
  # Given an id of a user who has shown interest in the current user;
  # Defines a training set 
  # -or- 
  # Adds said user into the existing training set, containing;
  #    1. user names
  #    2. word usage by user
  #    3. total word usage, and word usage by the group that has shown interest
  #       and those that have not.
  def initializer(id)
    newFriend = User.find_by(id: id)
    friendHash = {"name"=>newFriend.id,"words"=>newFriend.bucket,"location"=>newFriend.location}
	if trainData == {}
	  nonFriend = User.find_by(id: rand(User.all.length))
	  while nonFriend.id == newFriend.id
	    nonFriend = User.find_by(id: rand(User.all.length))
      end
	else
	  nonFriend = User.find_by(id: rand(User.all.length))
	  while trainData["Friends"][nonFriend.id] != nil
	    nonFriend = User.find_by(id: rand(User.all.length))
      end
	end
	nonFriendHash = {"name"=>nonFriend.id,"words"=>nonFriend.bucket,"location"=>nonFriend.location}
	if trainData == {}
	  total = peerBucket
	  fname = friendHash["name"]
	  nname = nonFriendHash["name"]
	  friends = {fname => 1, "words" => peerBucket}
	  nonFriends = {nname => 0, "words" => peerBucket}
	  total = total.each{|key,value| if friendHash["words"][key] == nil and nonFriendHash["words"][key] == nil
										total[key] = total.length
										friends["words"][key] = 1
										nonFriends["words"][key] = 1
									 else
										if friendHash["words"][key] == nil
										   friends["words"][key] = 1
										   nonFriends["words"][key] = nonFriendHash["words"][key].to_i+1
										elsif nonfriendHash["words"][key] == nil
										   nonFriends["words"][key] = 1
										   friends["words"][key] = friendHash["words"][key].to_i+1
										else
										   friends["words"][key] = friendHash["words"][key].to_i+1
										   nonFriends["words"][key] = nonFriendHash["words"][key].to_i+1
										end
										total[key] = friends["words"][key].to_i+nonFriends["words"][key].to_i+total.length
									end}
	else
	  total = trainData["total"]
	  friends = trainData["friends"]
	  nonfriends = trainData["nonfriends"]
	  friends[friendHash["name"]] = 1
	  nonfriends[nonfriendHash["name"]] = 0
	  total = total.each{|key,value| if friendHash["words"][key] == nil and nonFriendHash["words"][key] == nil
										friends["words"][key] = friends["words"][key] + 1
										nonfriends["words"][key] = nonfriends["words"][key] + 1
									 else
										if friendHash["words"][key] == nil
										   friends["words"][key] = friends["words"][key] + 1
										   nonfriends["words"][key] = nonFriendHash["words"][key]+nonfriends["words"][key] +1
										else
										   nonfriends["words"][key] = nonfriends["words"][key] +1
										   friends["words"][key] = friendHash["words"][key]+friends["words"][key] +1
										end   
										total[key] = friend["words"][key]+nonfriends["words"][key]+total.length
									 end}
	end
	update_attribute(:trainData, {"total"=>total,"friends"=>friends,"non_friends"=>nonFriends})
 end
 
  # Using the current user's training set this calculates;
  # 1. The prior probability of the two classes (will show interest vs won't)
  # 2. The conditional probability of each word being in associated with a
  #    certain class. This is in the form of a matrix for ease in classification.
  def liklihood_and_priors
    m1 = Matrix[]
	m2 = Matrix[]
    train = trainData
	m1 = eval(train["total"]).map{|feature,count| Matrix.columns(m1.to_a << eval(train["friends"])["words"][feature].to_i/ count)}
	m2 = eval(train["total"]).map{|feature,count| Matrix.columns(m2.to_a << eval(train["non_friends"])["words"][feature].to_i/ count)}
	prior1 = 0.5
	prior2 = 0.5
	train["conditionalProbs_friends"] = m1
	train["conditionalProbs_nonfriends"] = m2
	train["priors"] = [prior1,prior2]
	update_attribute(:trainData, train)
  end
  
  # Given a test user returns the probability that said user would show interest;
  #    - It does so by using the training data, its conditional probabilities
  #    - for friends and non friends and applying a linear classifier in the
  #    - form of log(prior_class-i) + log(matrix of conditional_probs_class-i)
  #                                 * test user's word usage
  # Check out, https://en.wikipedia.org/wiki/Naive_Bayes_classifier#Multinomial_naive_Bayes
  # for a more thorough explanation of the theory
  def classify(testUser)
    total = trainData["total"]
	words = testUser.bucket
	count = Matrix[]
	count = total.map{|feature| if words[feature] == nil
	                               Matrix.rows(count.to_a << 1)
								else
								   Matrix.rows(count.to_a << words[feature] + 1)
								end}
	predictFriend = Math.log(trainData["priors"][1]) + count*Math.log(trainData["conditionalProbs_friends"])
    predictNon = Math.log(trainData["priors"][1]) + count*Math.log(trainData["conditionalProbs_friends"])
    if predictFriend > predictNon
	   active_relationships.find_by(followed_id: testUser.id).update_attribute(:rank, predictFriend)
	else
	   active_relationships.find_by(followed_id: testUser.id).update_attribute(:rank, -predictNon)
	end
  end
  
  private
  
    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end