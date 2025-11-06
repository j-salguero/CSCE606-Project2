Feature: My Wishlist basics

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
