class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, 
              :trial,
              :days,
              :evernote_key,
  			      :instagram_key,
  			      :facebook_key,
  			      :twitter_key,
  			      :twitter_secret,
  			      :twitter_status,
  			      :instagram_status,
  			      :evernote_status,
  			      :pocket_status,
              :tweet,
              :tweet_quantity

  has_many :tasks

  acts_as_follower
end
