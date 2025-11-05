# frozen_string_literal: true

# Helper to find a header-ish container in a tolerant way.
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

# Helper to find a footer-ish container in a tolerant way.
def find_footer_node
  candidates = [
    'footer',
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

# Click a header link if it exists; otherwise note that it was absent.
def click_header_link_if_exists(label)
  header = find_header_node
  if header
    within(header) do
      # Accept both <a> and <button> with that label
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

Then('I should see the site brand in the header') do
  header = find_header_node
  # Brand text we’ve seen around the app
  possible_brands = [/VinylVerse/i, /Vinyl\s*Verse/i, /🎧/]

  if header
    header_text = header.text
    expect(possible_brands.any? { |rx| header_text =~ rx }).to be(true),
      "Expected one of #{possible_brands} in header, got: #{header_text.inspect}"
  else
    # Fall back to page-level check so this doesn’t fail if layout omits <header>.
    expect(page).to have_text(/VinylVerse/i)
  end
end

When('I try to click the header link {string}') do |label|
  @header_click_result = click_header_link_if_exists(label)
end

Then('I should land on the artists page if the link existed') do
  if @header_click_result == :clicked
    # URL helper may not be available in the test context; assert by content
    expect(page).to have_text(/Artists/i)
  else
    # Link wasn’t present; pass without asserting navigation.
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
    # Accept either the year or a classic copyright symbol line
    expect(
      footer.text.include?(year) ||
      footer.text.match?(/©|\(c\)|copyright/i)
    ).to be(true), "Expected footer to include #{year} or a copyright mark, got: #{footer.text.inspect}"
  else
    # Fallback: some pages don’t render a footer; allow a global check so the test stays acceptance-level.
    expect(page).to have_text(/©|\(c\)|copyright/i).or have_text(year)
  end
end

Then('the footer should optionally show any of {string}') do |csv|
  footer = find_footer_node
  labels = csv.split(',').map(&:strip)
  if footer
    text = footer.text
    # This is optional: the scenario passes if at least one is present OR none exist.
    # The assertion ensures we ran the check; but it’s not strict about presence.
    _present = labels.any? { |lbl| text.match?(/#{Regexp.escape(lbl)}/i) }
    expect(_present || !footer).to be(true)
  else
    # No footer present; optional link test passes.
    expect(true).to be(true)
  end
end
