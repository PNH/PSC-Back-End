json.extract! user_connection, :id, :created_at, :updated_at
json.url user_connection_url(user_connection, format: :json)