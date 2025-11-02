json.extract! artist, :id, :name, :genre, :country, :created_at, :updated_at
json.url artist_url(artist, format: :json)
