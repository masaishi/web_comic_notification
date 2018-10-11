json.extract! comic, :id, :name, :url, :latest_story, :created_at, :updated_at
json.url comic_url(comic, format: :json)
