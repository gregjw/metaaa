count = User.count
i = 1

while i <= count
	user = User.find(i)
	days = user[:days]
	
	if days >= 1
		days = days - 1
	end

	user.update_attribute(:days, days) 
	i = i + 1
end