Feature: HomeController works

  Scenario: Home index renders
    When I visit the home controller page
    Then I should see "VinylVerse"
