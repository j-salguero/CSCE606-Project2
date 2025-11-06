Feature: Adjusting My Wishlist

  Background:
    Given the database is clean

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
