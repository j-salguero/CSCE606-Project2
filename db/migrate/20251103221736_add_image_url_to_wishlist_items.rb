class AddImageUrlToWishlistItems < ActiveRecord::Migration[8.0]
  def change
    add_column :wishlist_items, :image_url, :string
  end
end
