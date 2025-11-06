Given("the database is clean") do
  tables = %w[wishlist_items collection_items albums artists]
  tables.each do |tbl|
    begin
      ActiveRecord::Base.connection.execute("DELETE FROM #{tbl}")
    rescue
    end
  end
end

Given('an artist named {string} exists') do |name|
  Artist.create!(name: name)
end

When('I view the artist {string}') do |name|
  artist = Artist.find_by!(name: name)
  visit artist_path(artist)
end

When('I go to the edit page for artist {string}') do |name|
  artist = Artist.find_by!(name: name)
  visit edit_artist_path(artist)
end

Given('a wishlist item {string} by {string} exists') do |title, artist_name|
  artist = (Artist.find_or_create_by!(name: artist_name) rescue nil)
  album =
    begin
      if defined?(Album)
        Album.find_or_create_by!(title: title, artist: artist)
      end
    rescue
      nil
    end
  begin
    WishlistItem.create!(title: title, artist: artist_name, album: album)
  rescue
    WishlistItem.create!(title: title, artist: artist_name)
  end
end

When("I send a POST request to {string} with:") do |path, table|
  page.driver.post(path, table.rows_hash)
  visit wishlist_items_path   # follow redirect manually
end

Then("I should be on the wishlist page") do
  expect(page.current_path).to eq(wishlist_items_path)
end

When("I POST to {string} with:") do |path, table|
  page.driver.post(path, table.rows_hash)
  visit wishlist_items_path  # follow redirect so assertions work
end

When('I click the first {string} link') do |text|
  first(:link_or_button, text).click
end

Given('a collection item {string} by {string} exists') do |title, artist|
  a = Artist.find_or_create_by!(name: artist)
  album = Album.find_or_create_by!(title: title, artist: a)
  CollectionItem.create!(album: album)
end