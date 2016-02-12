json.array!(@databases) do |database|
  json.extract! database, :id, :name, :type, :user
  json.url database_url(database, format: :json)
end
