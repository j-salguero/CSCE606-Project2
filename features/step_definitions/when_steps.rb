When('I add any album to my collection') { click_first_add_to_collection_outside_collection_section }
When('I add any album to my wishlist')   { click_first_add_to_wishlist_outside_wishlist_section }
When('I remove any album from my collection') { click_first_remove_from_collection }
When('I remove any album from my wishlist')   { click_first_remove_from_wishlist }

When('I fill in {string} with {string}') do |label, value|
  fill_in(label, with: value)
end

When('I press {string}') do |text|
  if page.has_button?(text, exact: true)
    click_button(text)
  elsif page.has_button?(text, exact: false)
    click_button(text, exact: false)
  else
    find('input[type="submit"], button[type="submit"]', match: :first).click
  end
end

When('I click {string}') do |text|
  if page.has_link?(text, exact: true)
    click_link(text)
  elsif page.has_button?(text, exact: true)
    click_button(text)
  elsif page.has_link?(text, exact: false)
    click_link(text, exact: false)
  elsif page.has_button?(text, exact: false)
    click_button(text, exact: false)
  else
    find(:xpath, "//*[normalize-space(text())=#{xpath_text_literal(text)}]", match: :first).click
  end
end

When('I click the first {string}') do |text|
  if page.has_link?(text, exact: true, wait: 0.5)
    first(:link, text, exact_text: true).click
  elsif page.has_button?(text, exact: true, wait: 0.5)
    first(:button, text, exact: true).click
  else
    first(:xpath, "//*[normalize-space(text())=#{xpath_text_literal(text)}]").click
  end
end

When('I remove the collection item {string}') do |title|
  collection_scope = first(:xpath, "//*[contains(normalize-space(.), 'My Collection')]", match: :first)
  within(collection_scope) do
    card = find(:xpath,
      ".//*[.//text()[normalize-space()=#{xpath_text_literal(title)}] " \
      "and (.//button[normalize-space()='Remove from Collection'] or .//a[normalize-space()='Remove from Collection'])][1]",
      match: :first
    )
    within(card) do
      if page.has_button?('Remove from Collection', exact: true, wait: 0.5)
        click_button('Remove from Collection', exact: true)
      else
        find(:xpath, ".//a[normalize-space()='Remove from Collection']", match: :first).click
      end
    end
  end
end

When('I remove the wishlist item {string}') do |title|
  wishlist_scope = first(:xpath, "//*[contains(normalize-space(.), 'My Wishlist') or contains(normalize-space(.), 'Wishlist')]", match: :first)
  within(wishlist_scope) do
    card = find(:xpath,
      ".//*[.//text()[normalize-space()=#{xpath_text_literal(title)}] " \
      "and (.//button[normalize-space()='Remove from Wishlist'] or .//a[normalize-space()='Remove from Wishlist'])][1]",
      match: :first
    )
    within(card) do
      if page.has_button?('Remove from Wishlist', exact: true, wait: 0.5)
        click_button('Remove from Wishlist', exact: true)
      else
        find(:xpath, ".//a[normalize-space()='Remove from Wishlist']", match: :first).click
      end
    end
  end
end

When('I add {string} by {string} to my wishlist') do |album, artist|
  WishlistItem.create!(title: album, artist: artist)
  visit '/wishlist_items'
end

When('I try to click the header link {string}') do |label|
  @header_click_result = click_header_link_if_exists(label)
end

When('I view the artist {string}') do |name|
  artist = Artist.find_by!(name: name)
  visit artist_path(artist)
end

When('I go to the edit page for artist {string}') do |name|
  artist = Artist.find_by!(name: name)
  visit edit_artist_path(artist)
end

When("I send a POST request to {string} with:") do |path, table|
  page.driver.post(path, table.rows_hash)
  visit wishlist_items_path   # follow redirect manually
end

When("I POST to {string} with:") do |path, table|
  page.driver.post(path, table.rows_hash)
  visit wishlist_items_path  # follow redirect so assertions work
end

When('I click the first {string} link') do |text|
  first(:link_or_button, text).click
end

When("I send a collection POST request to {string} with:") do |path, table|
  params = table.rows_hash
  page.driver.post(path, params)
  visit collection_items_path
end

When("I visit the home page")        { visit root_path }
When("I go to the artists page")     { visit artists_path }
When("I go to the new artist page")  { visit new_artist_path }
When("I go to the collection page")  { visit collection_items_path }
When("I go to the wishlist page")    { visit wishlist_items_path }
When('I visit {string}')             { |path| visit path }

When("I visit the home controller page") do
  visit "/home/index"
end

When('I sign up with name {string}, email {string}, password {string}') do |name, email, password|
  fill_in "Name", with: name
  fill_in "Email", with: email
  fill_in "Password", with: password
  fill_in "Confirm Password", with: password
  click_button "Create Account"
end

When('I log in with email {string} and password {string}') do |email, password|
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Login"
end

When("I log out") do
  click_link("Log Out") rescue nil
  click_link("Logout") rescue nil
  click_link("Sign Out") rescue nil
  click_link("Log off") rescue nil

  first(:link, /log\s*out|sign\s*out/i)&.click rescue nil

  first('a[href*="logout"], a[href*="sign_out"]', match: :first)&.click rescue nil

  first('a[data-method="delete"]', match: :first)&.click rescue nil
end

When("I post to {string} with:") do |path, table|
  params = table.rows_hash
  page.driver.post(path, params:)
  visit current_path
end
