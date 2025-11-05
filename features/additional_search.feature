Feature: Search edge cases

  Background:
    Given Discogs returns 1 artist result for "The Beatles" (id 82730)

  Scenario: Whitespace-only artist query shows search form
    When I visit "/search?artist_name=   &commit=Search+Artist"
    Then I should see "Search VinylVerse"
    And I should see "Search by Artist"

  Scenario: Mixed-case name still finds results
    When I visit "/search?artist_name=the BEATLES&commit=Search+Artist"
    Then I should see "The Beatles"
