Before { @counts = {} }

Given('I note the collection count')  { @counts[:collection_before] = count_collection_items }
Given('I note the wishlist count')    { @counts[:wishlist_before] = count_wishlist_items }

Given('Discogs returns {int} artist result for {string} \(id {int}\)') do |_n, _q, _id|
end

Given('Discogs returns 0 results for {string}') do |_q|
end

Given('Discogs responds with rate limit for {string}') do |_q|
  stub_request(:get, %r{\Ahttps://api\.discogs\.com/database/search})
    .to_return(
      status: 429,
      headers: { "Content-Type" => "application/json",
                 "X-Discogs-Ratelimit-Remaining" => "0" },
      body: { message: "Rate limit exceeded" }.to_json
    )
end

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

Given('a collection item {string} by {string} exists') do |title, artist|
  a = Artist.find_or_create_by!(name: artist)
  album = Album.find_or_create_by!(title: title, artist: a)
  CollectionItem.create!(album: album)
end

Given('no user exists with email {string}') do |email|
  User.where(email: email).delete_all
end

Given('I am on the wishlist page') do
  visit '/wishlist_items'
end

Given('I am logged out') do
  visit '/logout' rescue nil
  visit '/login'
end

Given("I am on the login page") do
  visit "/"   
end

Given('a user exists with name {string}, email {string}, password {string}') do |name, email, password|
  User.where(email: email).delete_all
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password
  )
end

Given('I am on the signup page') do
  visit '/signup'
end

Given("an album titled {string} by {string} exists without image") do |title, artist_name|
  artist = Artist.find_or_create_by!(name: artist_name)
  Album.create!(title:, artist:, image_url: nil)
end

Given("a collection item for {string} exists") do |title|
  album = Album.find_by!(title: title)
  CollectionItem.create!(album: album)
end

Given("an album titled {string} by {string} exists") do |title, artist_name|
  artist = Artist.find_or_create_by!(name: artist_name)
  Album.create!(title: title, artist: artist)
end
