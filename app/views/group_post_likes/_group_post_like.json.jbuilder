json.extract! group_post_like, :id, :group_id, :post_id, :user_id, :status, :created_at, :updated_at
json.url group_post_like_url(group_post_like, format: :json)