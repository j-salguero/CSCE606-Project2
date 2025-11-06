Feature: My Collection basics

  Background:
    Given the database is clean

  Scenario: Collection page renders
    When I go to the collection page
    Then I should see "Collection"
    And I should see "My Collection"

  Scenario: Collection shows a seeded item
    Given a collection item "Abbey Road" by "The Beatles" exists
    When I go to the collection page
    Then I should see "Abbey Road"
    And I should see "The Beatles"

  Scenario: Collection shows multiple seeded items
    Given a collection item "Rumours" by "Fleetwood Mac" exists
    And a collection item "Purple Rain" by "Prince" exists
    When I go to the collection page
    Then I should see "Rumours"
    And I should see "Purple Rain"
