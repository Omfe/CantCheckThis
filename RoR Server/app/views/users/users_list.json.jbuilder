json.array!(@users) do |user|
  json.(user, :first_name, :points)
  
  json.schedule do
    json.check_in user.schedule.check_in
	json.check_out user.schedule.check_out
  end
  
end
  