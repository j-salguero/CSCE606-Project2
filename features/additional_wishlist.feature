Feature: Wishlist extra flows

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
