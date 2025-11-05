Feature: Artists extra flows

  Background:
    Given the database is clean

  Scenario: Artists index lists multiple artists
    Given an artist named "The Beatles" exists
    And an artist named "Fleetwood Mac" exists
    When I go to the artists page
    Then I should see "The Beatles"
    And I should see "Fleetwood Mac"

  Scenario: Artist show page has a delete link (non-destructive)
    Given an artist named "Adele" exists
    When I view the artist "Adele"
    Then I should see "Destroy this artist"
