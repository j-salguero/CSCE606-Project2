class CreateWishlistItems < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlist_items do |t|
      t.string :user_id
      t.string :artist_id
      t.datetime :added_at
      t.timestamps
    end
  end
end
