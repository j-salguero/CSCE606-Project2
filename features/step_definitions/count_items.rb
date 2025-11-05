# frozen_string_literal: true

# --- Small utilities --------------------------------------------------------

def xpath_text_literal(str)
  if str.include?("'") && str.include?('"')
    parts = str.split("'").map { |p| "'#{p}'" }
    %(concat(#{parts.join(%{, "'", })}))
  elsif str.include?("'")
    %("#{str}")
  else
    %('#{str}')
  end
end

def try_within_section(label_regexps)
  nodes = all(:xpath, "//*", minimum: 1)
  node = nodes.find { |n| label_regexps.any? { |rx| n.text.to_s =~ rx } }
  return false unless node
  within(node) { yield }
  true
end

def ensure_on_collection_page!
  # Reuse your navigation step so routes/helpers stay in one place.
  # (Calling Cucumber steps from steps is OK here.)
  step 'I go to the collection page'
end

# --- Count helpers (with fallback to collection page) -----------------------

def count_collection_items
  # Try current page first
  got = false
  count = 0
  got = try_within_section([/My Collection/i, /Collection\b/i]) do
    count = all(:xpath, ".//button[normalize-space()='Remove from Collection'] | .//a[normalize-space()='Remove from Collection']").size
  end
  return count if got

  # Fallback: go to collection page and try again
  ensure_on_collection_page!
  got = try_within_section([/My Collection/i, /Collection\b/i]) do
    count = all(:xpath, ".//button[normalize-space()='Remove from Collection'] | .//a[normalize-space()='Remove from Collection']").size
  end
  raise "Could not find a Collection section to count" unless got
  count
end

def count_wishlist_items
  got = false
  count = 0
  got = try_within_section([/My Wishlist/i, /\bWishlist\b/i]) do
    count = all(:xpath, ".//button[normalize-space()='Remove from Wishlist'] | .//a[normalize-space()='Remove from Wishlist']").size
  end
  return count if got

  ensure_on_collection_page!
  got = try_within_section([/My Wishlist/i, /\bWishlist\b/i]) do
    count = all(:xpath, ".//button[normalize-space()='Remove from Wishlist'] | .//a[normalize-space()='Remove from Wishlist']").size
  end
  raise "Could not find a Wishlist section to count" unless got
  count
end

# --- Click helpers (with smart scoping + fallback) --------------------------

def click_first_add_to_collection_outside_collection_section
  # Prefer Explore/Search areas if present
  btn = nil
  [[/Explore Albums/i], [/Search VinylVerse/i, /Search by Artist/i]].each do |rxs|
    next unless try_within_section(rxs) do
      if page.has_button?('Add to Collection', wait: 0.5)
        btn = first(:button, 'Add to Collection', exact: true)
      else
        btn = first(:xpath, ".//a[normalize-space()='Add to Collection']", match: :first)
      end
    end
    break if btn
  end

  # If nothing found yet, ensure we’re on the collection page (which has Explore)
  unless btn
    ensure_on_collection_page!
    try_within_section([/Explore Albums/i]) do
      if page.has_button?('Add to Collection', wait: 0.5)
        btn = first(:button, 'Add to Collection', exact: true)
      else
        btn = first(:xpath, ".//a[normalize-space()='Add to Collection']", match: :first)
      end
    end
  end

  # Last resort: any Add to Collection not inside My Collection
  unless btn
    btn = first(:xpath,
      "(//button[normalize-space()='Add to Collection'] | //a[normalize-space()='Add to Collection'])" \
      "[not(ancestor::*[contains(normalize-space(.), 'My Collection')])]",
      match: :first
    )
  end

  raise Capybara::ElementNotFound, 'Could not find an "Add to Collection" control' unless btn
  btn.click
end

def click_first_add_to_wishlist_outside_wishlist_section
  btn = nil
  [[/Explore Albums/i], [/Search VinylVerse/i, /Search by Artist/i]].each do |rxs|
    next unless try_within_section(rxs) do
      if page.has_button?('Add to Wishlist', wait: 0.5)
        btn = first(:button, 'Add to Wishlist', exact: true)
      else
        btn = first(:xpath, ".//a[normalize-space()='Add to Wishlist']", match: :first)
      end
    end
    break if btn
  end

  unless btn
    ensure_on_collection_page!
    try_within_section([/Explore Albums/i]) do
      if page.has_button?('Add to Wishlist', wait: 0.5)
        btn = first(:button, 'Add to Wishlist', exact: true)
      else
        btn = first(:xpath, ".//a[normalize-space()='Add to Wishlist']", match: :first)
      end
    end
  end

  unless btn
    btn = first(:xpath,
      "(//button[normalize-space()='Add to Wishlist'] | //a[normalize-space()='Add to Wishlist'])" \
      "[not(ancestor::*[contains(normalize-space(.), 'My Wishlist') or contains(normalize-space(.), 'Wishlist')])]",
      match: :first
    )
  end

  raise Capybara::ElementNotFound, 'Could not find an "Add to Wishlist" control' unless btn
  btn.click
end

def click_first_remove_from_collection
  # If we’re not already in a section, go to collection page
  unless try_within_section([/My Collection/i, /Collection\b/i]) { true }
    ensure_on_collection_page!
  end
  try_within_section([/My Collection/i, /Collection\b/i]) do
    if page.has_button?('Remove from Collection', wait: 0.5)
      first(:button, 'Remove from Collection', exact: true).click
    else
      first(:xpath, ".//a[normalize-space()='Remove from Collection']", match: :first).click
    end
  end
end

def click_first_remove_from_wishlist
  unless try_within_section([/My Wishlist/i, /\bWishlist\b/i]) { true }
    ensure_on_collection_page!
  end
  try_within_section([/My Wishlist/i, /\bWishlist\b/i]) do
    if page.has_button?('Remove from Wishlist', wait: 0.5)
      first(:button, 'Remove from Wishlist', exact: true).click
    else
      first(:xpath, ".//a[normalize-space()='Remove from Wishlist']", match: :first).click
    end
  end
end

# --- State holder -----------------------------------------------------------

Before { @counts = {} }

# --- Steps ------------------------------------------------------------------

Given('I note the collection count')  { @counts[:collection_before] = count_collection_items }
Given('I note the wishlist count')    { @counts[:wishlist_before] = count_wishlist_items }

When('I add any album to my collection') { click_first_add_to_collection_outside_collection_section }
When('I add any album to my wishlist')   { click_first_add_to_wishlist_outside_wishlist_section }
When('I remove any album from my collection') { click_first_remove_from_collection }
When('I remove any album from my wishlist')   { click_first_remove_from_wishlist }

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
