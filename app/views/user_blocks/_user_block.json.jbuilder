json.extract! user_block, :id, :user_id, :context, :expires_at, :blocker_id, :reason, :created_at, :updated_at
json.url user_block_url(user_block, format: :json)
