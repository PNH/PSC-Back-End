json.extract! group_post_comment, :id, :user_id, :group_post, :comment, :parent_id, :created_at, :updated_at
json.url group_post_comment_url(group_post_comment, format: :json)