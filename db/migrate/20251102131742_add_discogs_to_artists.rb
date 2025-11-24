class AddDiscogsToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :discogs_id, :string
    add_column :artists, :discogs_uri, :string
  end
end
