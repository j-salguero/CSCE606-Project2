Feature: Header and footer basics
  # These scenarios are intentionally short, clear, and independent.
  # They verify the site header shows the brand and (if present) nav links,
  # and that the footer renders with a sensible copyright line.

  Background:
    # No DB state required for pure layout checks.
    # Home works unauthenticated in this app.
    When I visit the home page

  Scenario: Header shows site brand
    Then I should see the site brand in the header

  Scenario: Header has a link to Artists (if present, it should work)
    When I try to click the header link "Artists"
    Then I should land on the artists page if the link existed

  Scenario: Header has a link to Collection (if present)
    When I try to click the header link "Collection"
    Then I should land on the collection page if the link existed

  Scenario: Header has a link to Wishlist (if present)
    When I try to click the header link "Wishlist"
    Then I should land on the wishlist page if the link existed

  Scenario: Footer shows current year or a copyright line
    Then I should see the current year in the footer or a copyright line

  Scenario: Footer has optional policy links (Privacy/Terms/About)
    Then the footer should optionally show any of "Privacy,Terms,About"
