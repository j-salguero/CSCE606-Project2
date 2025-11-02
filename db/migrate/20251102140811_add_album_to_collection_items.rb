class AddAlbumToCollectionItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :collection_items, :album, null: false, foreign_key: true
  end
end
