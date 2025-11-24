class AddTitleAndArtistToCollectionItems < ActiveRecord::Migration[8.0]
  def change
    add_column :collection_items, :title, :string
    add_column :collection_items, :artist, :string
  end
end
