Feature: Search Functionality

  Background:
    Given Discogs returns 1 artist result for "The Beatles" (id 82730)

  Scenario: Empty artist query shows empty search form
    When I visit "/search?artist_name=   &commit=Search+Artist"
    Then I should see "Search VinylVerse"
    And I should see "Search by Artist"

  Scenario: Mix of upper and lower case letters still finds results
    When I visit "/search?artist_name=the BEATLES&commit=Search+Artist"
    Then I should see "The Beatles"

  Scenario: Search by album shows results
    When I visit "/search?album_name=Abbey+Road&commit=Search+Album"
    Then I should see "Abbey Road"
