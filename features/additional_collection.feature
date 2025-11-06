Feature: Adjusting My Collection

  Background:
    Given the database is clean

  Scenario: Adding increases collection count
    When I go to the collection page
    And I note the collection count
    And I add any album to my collection
    Then the collection count should increase by 1

  Scenario: Removing decreases collection count
    When I go to the collection page
    And I add any album to my collection
    And I note the collection count
    And I remove any album from my collection
    Then the collection count should decrease by 1

  Scenario: Destroy removes an item and shows a notice
    Given a collection item "Selfish Machines" by "Pierce The Veil" exists
    When I visit "/collection_items"
    And I click the first "Remove from Collection" link
    Then I should be on the collection page
    And I should see "Selfish Machines removed from your collection"
