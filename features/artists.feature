Feature: Artists CRUD and views

  Background:
    Given the database is clean

  Scenario: Artists index loads
    When I go to the artists page
    Then I should see "Artists"

  Scenario: Artists index shows table headers
    Given an artist named "Table Probe" exists
    When I go to the artists page
    Then I should see "Artists"
    And I should see "Name"
    And I should see "Albums"

  Scenario: Create artist with valid name
    When I go to the new artist page
    And I fill in "Name" with "Fleetwood Mac"
    And I press "Create"
    Then I should see "Fleetwood Mac"

  Scenario: Create artist with missing name shows error
    When I go to the new artist page
    And I press "Create"
    Then I should see "Name can't be blank"

  Scenario: Artist show page displays record
    Given an artist named "The Beatles" exists
    When I view the artist "The Beatles"
    Then I should see "The Beatles"

  Scenario: Lookup fails when no name is provided
    Given the database is clean
    When I visit "/artists/lookup?name="
    Then I should see "No artist name provided."

  Scenario: Lookup succeeds for an existing artist
    Given the database is clean
    And an artist named "Adele" exists
    When I visit "/artists/lookup?name=Adele"
    Then I should see "Adele"

