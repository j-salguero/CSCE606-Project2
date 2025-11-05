Feature: Discogs extra cases

  Background:
    Given the database is clean
    And Discogs returns 1 artist result for "The Beatles" (id 82730)
    And Discogs returns 0 results for "Nonexistent Person"

  Scenario: Lookup shows numeric count of releases
    When I visit "/artists/lookup?name=The Beatles"
    Then I should see "Releases on Discogs: 2"

  Scenario: Lookup shows unknown genre/country with dashes
    When I visit "/artists/lookup?name=Nonexistent Person"
    Then I should see "Genre: -"
    And I should see "Country: -"
