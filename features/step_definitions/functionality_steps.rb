# Form filling + robust, scoped clicking (avoid ambiguity)

def xpath_text_literal(s)
  if s.include?("'")
    parts = s.split("'").map { |p| "'#{p}'" }
    "concat(#{parts.join(%q{, "'", })})"
  else
    "'#{s}'"
  end
end

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

# --- helpers stay as-is (xpath_text_literal, etc.) ---

# Precise removal in Collection area: pick the ONE card that has the title AND the "Remove from Collection" control.
When('I remove the collection item {string}') do |title|
  # Scope to the Collection section to avoid sidebar duplicates
  collection_scope = first(:xpath, "//*[contains(normalize-space(.), 'My Collection')]", match: :first)
  within(collection_scope) do
    # Find the nearest ancestor container that has the title AND a matching control
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

# Precise removal in Wishlist area: pick the ONE card that has the title AND the "Remove from Wishlist" control.
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

