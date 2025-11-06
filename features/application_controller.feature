Feature: Application controller behavior

  Scenario: Guest sees logged-out header
    When I visit the home page
    Then I should see "Don't have an account? Create one here"
    And I should not see "Log out"

  Scenario: current_user is available to views after login
    Given a user exists with name "Alice", email "alice@example.com", password "password123"
    And I am on the login page
    When I log in with email "alice@example.com" and password "password123"
    Then I should see "Alice"
    And I should see "Logout"

  Scenario: Logout clears the session
    Given a user exists with name "Bob", email "bob@example.com", password "secret123"
    And I am on the login page
    When I log in with email "bob@example.com" and password "secret123"
    And I log out
    Then I should see "Welcome back to VinylVerse"


