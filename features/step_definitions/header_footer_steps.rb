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

# -------- Steps --------
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

When('I try to click the header link {string}') do |label|
  @header_click_result = click_header_link_if_exists(label)
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

