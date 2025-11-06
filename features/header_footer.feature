Feature: Header and footer basic functionality
  
  Background:
    When I visit the home page

  Scenario: Header shows site brand
    Then I should see the site brand in the header

  Scenario: Header has a link to Artists
    When I try to click the header link "Artists"
    Then I should land on the artists page if the link existed

  Scenario: Header has a link to Collection
    When I try to click the header link "Collection"
    Then I should land on the collection page if the link existed

  Scenario: Header has a link to Wishlist
    When I try to click the header link "Wishlist"
    Then I should land on the wishlist page if the link existed

  Scenario: Footer shows current year or a copyright line
    Then I should see the current year in the footer or a copyright line

  Scenario: Footer exposes contact links (phone and email)
    Then the footer should have a phone and email link
