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

def xpath_text_literal(s)
  if s.include?("'")
    parts = s.split("'").map { |p| "'#{p}'" }
    "concat(#{parts.join(%q{, "'", })})"
  else
    "'#{s}'"
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
  step 'I go to the collection page'
end

def count_collection_items
  got = false
  count = 0
  got = try_within_section([/My Collection/i, /Collection\b/i]) do
    count = all(:xpath, ".//button[normalize-space()='Remove from Collection'] | .//a[normalize-space()='Remove from Collection']").size
  end
  return count if got

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

def click_first_add_to_collection_outside_collection_section
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

def find_header_node
  candidates = [
    'header',
    'nav[role="navigation"]',
    'nav.site-nav',
    '.navbar',
    '.site-header',
    'div.header',
  ]
  candidates.each do |sel|
    nodes = all(:css, sel, minimum: 0, wait: 0)
    return nodes.first if nodes.any?
  end
  nil
end

def find_footer_node
  candidates = [
    'footer',
    '[class*="footer"]',
    '[id*="footer"]',
    '.site-footer',
    'div.footer',
    'div#footer',
  ]
  candidates.each do |sel|
    nodes = all(:css, sel, minimum: 0, wait: 0)
    return nodes.first if nodes.any?
  end
  nil
end

def click_header_link_if_exists(label)
  header = find_header_node
  if header
    within(header) do
      if has_link?(label, wait: 0)
        click_link(label)
        return :clicked
      elsif has_button?(label, wait: 0)
        click_button(label)
        return :clicked
      end
    end
  end
  :absent
end