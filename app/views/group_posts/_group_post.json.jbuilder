json.extract! group_post, :id, :user, :content, :status, :created_at, :updated_at
json.url group_post_url(group_post, format: :json)
