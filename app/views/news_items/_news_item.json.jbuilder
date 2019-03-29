json.extract! news_item, :id, :itemtype, :title, :pinned, :relevance, :body, :url, :created_at, :updated_at
json.url news_item_url(news_item, format: :json)
