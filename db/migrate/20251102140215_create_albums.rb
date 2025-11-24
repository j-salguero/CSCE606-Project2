class CreateAlbums < ActiveRecord::Migration[8.0]
  def change
    create_table :albums do |t|
      t.string :title
      t.integer :year
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
