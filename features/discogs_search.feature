Feature: Discogs lookup for artists

  Background:
    Given the database is clean
    And Discogs returns 1 artist result for "The Beatles" (id 82730)
    And Discogs returns 0 results for "Nonexistent Person"

  Scenario: Successful lookup shows Discogs section
    When I visit "/artists/lookup?name=The Beatles"
    Then I should see "The Beatles"
    And I should see "Releases on Discogs"
    And I should see "Genre:"

  Scenario: Lookup with no results shows zero count
    When I visit "/artists/lookup?name=Nonexistent Person"
    Then I should see "Nonexistent Person"
    And I should see "Releases on Discogs: 0"

  Scenario: Discogs rate limit
    Given Discogs responds with rate limit for "The Beatles"
    When I visit "/artists/lookup?name=The Beatles"
    Then I should see "The Beatles"
    And I should see "Releases on Discogs"

  Scenario: Lookup shows numeric count of releases
    When I visit "/artists/lookup?name=The Beatles"
    Then I should see "Releases on Discogs: 2"

  Scenario: Lookup shows unknown genre/country with dashes
    When I visit "/artists/lookup?name=Nonexistent Person"
    Then I should see "Genre: -"
    And I should see "Country: -"
