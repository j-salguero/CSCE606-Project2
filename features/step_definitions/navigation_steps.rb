# Navigation + simple assertions

When("I visit the home page")        { visit root_path }
When("I go to the artists page")     { visit artists_path }
When("I go to the new artist page")  { visit new_artist_path }
When("I go to the collection page")  { visit collection_items_path }
When("I go to the wishlist page")    { visit wishlist_items_path }
When('I visit {string}')             { |path| visit path }

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

