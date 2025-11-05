Feature: Safety and secrets

  Scenario: No secrets are leaked in UI
    When I visit the home page
    Then I should not see "DISCOGS_API_KEY"
    And I should not see "DISCOGS_TOKEN"
