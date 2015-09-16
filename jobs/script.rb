User.all.each do |user|
	days = user[:days]
	
	if days >= 1
		days = days - 1
	end

	user.update_attribute(:days, days)
end