json.array!(@check_ins) do |check_in|
  json.(check_in, :id, :checked_in_at)
  
  json.user do
    json.id check_in.user.id
  	json.first_name check_in.user.first_name
	json.email check_in.user.email
	json.points check_in.user.points
  end
  
end