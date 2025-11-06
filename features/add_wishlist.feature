Feature: Wishlist artist name extraction

  Scenario: Adding wishlist item without explicit artist uses fallback
    Given the database is clean
    When I send a POST request to "/wishlist_items" with:
      | release[title] | Hello Sunshine |
    Then I should be on the wishlist page
    And I should see "Hello Sunshine"
    And I should see "Unknown Artist"

  Scenario: Creating a duplicate shows alert
    Given a wishlist item "Rumours" by "Fleetwood Mac" exists
    When I POST to "/wishlist_items" with:
      | release[title] | Rumours |
      | release[artist]| Fleetwood Mac |
    Then I should be on the wishlist page
    And I should see "already in your wishlist"

  Scenario: Destroy removes and shows notice
    Given a wishlist item "Nevermind" by "Nirvana" exists
    When I visit "/wishlist_items"
    And I click the first "Remove from Wishlist" link
    Then I should be on the wishlist page
    And I should see "removed from your wishlist"
