Feature: Header and footer basics
  
  Background:
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

  Scenario: Footer exposes contact links (phone and email)
    Then the footer should have a phone and email link
