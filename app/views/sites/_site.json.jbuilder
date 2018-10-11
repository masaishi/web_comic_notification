json.extract! site, :id, :name, :url, :method, :created_at, :updated_at
json.url site_url(site, format: :json)
