json.array!(@schedules) do |schedule|
  json.extract! schedule, :id, :check_in, :check_out
  json.url schedule_url(schedule, format: :json)
end
