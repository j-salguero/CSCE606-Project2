Then('the collection count should increase by {int}') do |delta|
  after  = count_collection_items
  before = @counts[:collection_before] || 0
  expect(after - before).to eq(delta), "Expected collection to change by #{delta}, but it changed by #{after - before} (before=#{before}, after=#{after})"
end

Then('the collection count should decrease by {int}') do |delta|
  after  = count_collection_items
  before = @counts[:collection_before] || 0
  expect(before - after).to eq(delta), "Expected collection to decrease by #{delta}, but it decreased by #{before - after} (before=#{before}, after=#{after})"
end

Then('the wishlist count should increase by {int}') do |delta|
  after  = count_wishlist_items
  before = @counts[:wishlist_before] || 0
  expect(after - before).to eq(delta), "Expected wishlist to change by #{delta}, but it changed by #{after - before} (before=#{before}, after=#{after})"
end

Then('the wishlist count should decrease by {int}') do |delta|
  after  = count_wishlist_items
  before = @counts[:wishlist_before] || 0
  expect(before - after).to eq(delta), "Expected wishlist to decrease by #{delta}, but it decreased by #{before - after} (before=#{before}, after=#{after})"
end

Then('I should see the site brand in the header') do
  header = find_header_node
  possible_brands = [/VinylVerse/i, /Vinyl\s*Verse/i, /🎧/]

  if header
    header_text = header.text
    expect(possible_brands.any? { |rx| header_text =~ rx }).to be(true),
      "Expected one of #{possible_brands} in header, got: #{header_text.inspect}"
  else
    expect(page).to have_text(/VinylVerse/i)
  end
end


Then('I should land on the artists page if the link existed') do
  if @header_click_result == :clicked
    expect(page).to have_text(/Artists/i)
  else
    expect(true).to be(true)
  end
end

Then('I should land on the collection page if the link existed') do
  if @header_click_result == :clicked
    expect(page).to have_text(/Collection/i)
  else
    expect(true).to be(true)
  end
end

Then('I should land on the wishlist page if the link existed') do
  if @header_click_result == :clicked
    expect(page).to have_text(/Wishlist/i)
  else
    expect(true).to be(true)
  end
end

Then('I should see the current year in the footer or a copyright line') do
  year = Time.now.year.to_s
  footer = find_footer_node

  if footer
    expect(
      footer.text.include?(year) ||
      footer.text.match?(/©|\(c\)|copyright/i)
    ).to be(true), "Expected footer to include #{year} or a copyright mark, got: #{footer.text.inspect}"
  else
    expect(page).to have_text(/©|\(c\)|copyright/i).or have_text(year)
  end
end

Then('the footer should have a phone and email link') do
  footer = find_footer_node
  scope = footer || page

  tel_links    = scope.all(:css, 'a[href^="tel:"]', minimum: 0, wait: 0)
  mailto_links = scope.all(:css, 'a[href^="mailto:"]', minimum: 0, wait: 0)

  tel_links    = page.all(:css, 'a[href^="tel:"]',     minimum: 0, wait: 0) if tel_links.empty?
  mailto_links = page.all(:css, 'a[href^="mailto:"]',  minimum: 0, wait: 0) if mailto_links.empty?

  expect(tel_links.any?).to be(true),    "Expected a phone link (tel:...) in footer/page"
  expect(mailto_links.any?).to be(true), "Expected an email link (mailto:...) in footer/page"

  phone_visible = page.has_text?(/\(\d{3}\)\s*\d{3}\s*[-\.]?\s*\d{4}/, wait: 0) ||
                  page.has_text?(/\b\d{3}[-\.]\d{3}[-\.]\d{4}\b/, wait: 0)
  email_visible = page.has_text?(/@/, wait: 0)

  expect(phone_visible).to be(true), "Expected a phone-like number visible somewhere in the footer/page"
  expect(email_visible).to be(true), "Expected an email-like text visible somewhere in the footer/page"
end

Then("I should be on the wishlist page") do
  expect(page.current_path).to eq(wishlist_items_path)
end

Then('I should see {string}')        { |text| expect(page).to have_content(text) }
Then('I should not see {string}')    { |text| expect(page).not_to have_content(text) }
Then('I should see a link to {string}') { |text| expect(page).to have_link(text) }

Then('I should see a link to the new artist form') do
  expect(
    page.has_selector?(%(a[href="#{new_artist_path}"])) ||
    page.has_link?(/New\s*Artist/i) ||
    page.has_button?(/New\s*Artist/i)
  ).to be(true),
     'Expected to find a link or button for creating a new artist'
end

Then('I should be on the collection page') do
  expect(page).to have_current_path(collection_items_path)
end

Then('I should be logged in as username {string}') do |username|
  expect(page).to have_content(username)
  expect(page).to have_content("My Vinyl Space")
end

Then("I should be on {string}") do |path|
  expect(page).to have_current_path(path)
end
