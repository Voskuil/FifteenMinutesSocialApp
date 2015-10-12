# fifteenMinutes_app
This project is meant to be a social media app where artists may meet each other
via tags that connect users of similar interests. This project evolved from me
working on Michael Hartl's Ruby on Rails Tutorial in early September of 2015
and has since been growing to include more features from open-sources like 
Mailboxer and Geodata as well as custom made features to facillitate better
more efficient connection process between users.

The site is currently hosted on Heroku and can be viewed at;
enigmatic-temple-7761.herokuapps.com

*NOTE*
Currently the naive bayes classifier is not being run, however you can look under
app/controllers/user_controllers.rb to see the commented out-code where it is called,
app/models/user.rb under the functions initializer, liklihood_and_priors, and classify
to see how the classifier works.
For the theory behind the classifier here are some good resources;
https://class.coursera.org/nlp/lecture/28
https://en.wikipedia.org/wiki/Naive_Bayes_classifier#Multinomial_naive_Bayes

Enjoy!
