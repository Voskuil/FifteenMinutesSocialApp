# Users
# Generate 500 fake users and initialize all of their tables

#500.times do |n|
  #name  = Faker::Name.name
  #email = "example-#{n+1}@voskuilissupercool.org"
  #password = "password"
  #description = "#{Faker::Hacker.say_something_smart} ##{Faker::Hacker.noun} ##{Faker::Hacker.abbreviation} ##{Faker::Hacker.noun}"
  #interest = "#{Faker::Hacker.ingverb} #{Faker::Hacker.noun}, #{Faker::Hacker.abbreviation}, #{Faker::Hacker.noun}, #{Faker::Hacker.adjective} #{Faker::Hacker.noun}"
  #possLocs = ['jenks','broken arrow','tulsa','pittsburgh','pitt','carnegie mellon','boston','cambridge','new york city','chicago']
  #location = possLocs[rand(10)]
  #User.create!(name: name,
         #     email: email,
        #      password:              password,
       #       password_confirmation: password,
      #        activated: true,
     #         activated_at: Time.zone.now,
	#		  description: description,
	#		  interest: interest,
	#		  location: location)
	#		  
  # user = User.find_by(name: name)		  
 #  @contentPre = user.search_vector.split(" '").map{|c| c.split(":") }.map{|s| [s[0].tr("'",""),s[1].count(",")+1]}
#	  @contentPre.each do |c|
#	    if user.bucket[c[0]] == nil
#		   user.bucket[c[0]] = c[1]
#		else
#		   user.bucket[c[0]] = user.bucket[c[0]].to_i + c[1]
#		end
#	  end
#   user.update_attribute(:bucket, user.bucket)
#  
#end

# Posts
# Generate 50 posts for every user
users = User.order(:created_at).take(500)
50.times do
  #content = Faker::Lorem.paragraph
  users.each do |user| 
    post = user.posts.create!(content: Faker::Lorem.paragraph)
	time = post.created_at.to_f
	post.update_attribute(:rank, time)
  end
end


# Following relationships
# Hook up likeminded users among those generated
users = User.all
users.each do |user|
  @interestPre = user.interest.tr("?!#()'.-","").downcase.split(",")
  @interest = @interestPre.map{|c| c.rstrip.lstrip}
  @interest.each do |keyword|
 	user.findFriends(users, keyword, {})
  end
end