class AddTitleAndArtistToWishlistItems < ActiveRecord::Migration[8.0]
  def change
    add_column :wishlist_items, :title, :string
    add_column :wishlist_items, :artist, :string
  end
end
