Feature: App starts up

  Scenario: Home page loads
    When I visit the home page
    Then I should see "VinylVerse"

  Scenario: Home shows login form
    When I visit the home page
    Then I should see "Welcome Back to VinylVerse"
    And I should see "Email"
    And I should see "Password"

  Scenario: Home links to sign up
    When I visit the home page
    Then I should see "Don't have an account? Create one here"
