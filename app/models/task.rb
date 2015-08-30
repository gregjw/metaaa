class Task < ActiveRecord::Base
	belongs_to :user
	acts_as_followable
end
