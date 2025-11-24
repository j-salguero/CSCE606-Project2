Feature: Search works

  Background:
    Given Discogs returns 1 artist result for "The Beatles" (id 82730)

  Scenario: Search by artist shows results
    When I visit "/search?artist_name=The Beatles&commit=Search+Artist"
    Then I should see "The Beatles"

  Scenario: Visiting search page with no query shows search form
    When I visit "/search"
    Then I should see "Search VinylVerse"
    And I should see "Search by Artist"
    And I should see "Search by Album"
