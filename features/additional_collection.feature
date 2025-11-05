Feature: Collection extra flows

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
