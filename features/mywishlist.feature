Feature: My Wishlist functionality

  Background:
    Given the database is clean

  Scenario: Wishlist page loads
    When I go to the wishlist page
    Then I should see "My Wishlist"
    And I should see "Albums I want to add to my collection"

  Scenario: Wishlist shows a seeded item
    Given a wishlist item "Random Access Memories" by "Daft Punk" exists
    When I go to the wishlist page
    Then I should see "Random Access Memories"
    And I should see "Daft Punk"

  Scenario: Wishlist shows multiple seeded items
    Given a wishlist item "Nevermind" by "Nirvana" exists
    And a wishlist item "21" by "Adele" exists
    When I go to the wishlist page
    Then I should see "Nevermind"
    And I should see "21"

  Scenario: Adding increases wishlist count
    When I go to the collection page
    And I note the wishlist count
    And I add any album to my wishlist
    Then the wishlist count should increase by 1

  Scenario: Removing decreases wishlist count
    When I go to the collection page
    And I add any album to my wishlist
    And I note the wishlist count
    And I remove any album from my wishlist
    Then the wishlist count should decrease by 1

  Scenario: User can add an item to the wishlist
    Given the database is clean
    And I am on the wishlist page
    When I add "Test Album" by "Test Artist" to my wishlist
    Then I should see "Test Album"
    And I should see "Test Artist"

  Scenario: Adding wishlist item without explicit artist
    Given the database is clean
    When I send a POST request to "/wishlist_items" with:
      | release[title] | Hello Sunshine |
    Then I should be on the wishlist page
    And I should see "Hello Sunshine"
    And I should see "Unknown Artist"

  Scenario: Creating a duplicate shows error message
    Given a wishlist item "Rumours" by "Fleetwood Mac" exists
    When I POST to "/wishlist_items" with:
      | release[title] | Rumours |
      | release[artist]| Fleetwood Mac |
    Then I should be on the wishlist page
    And I should see "already in your wishlist"

  Scenario: Destroy removes and prints message
    Given a wishlist item "Nevermind" by "Nirvana" exists
    When I visit "/wishlist_items"
    And I click the first "Remove from Wishlist" link
    Then I should be on the wishlist page
    And I should see "removed from your wishlist"

