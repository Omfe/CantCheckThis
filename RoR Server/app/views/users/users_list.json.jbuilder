json.array!(@users) do |user|
  json.(user, :first_name, :points)
end
  