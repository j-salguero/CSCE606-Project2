class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :genre
      t.string :country

      t.timestamps
    end
  end
end
