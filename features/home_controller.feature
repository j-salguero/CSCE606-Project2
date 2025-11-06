Feature: HomeController basic response
  Scenario: Home index renders
    When I visit the home controller page
    Then I should see "VinylVerse"
