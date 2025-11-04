class AddImageUrlToAlbums < ActiveRecord::Migration[8.0]
  def change
    add_column :albums, :image_url, :string
  end
end
