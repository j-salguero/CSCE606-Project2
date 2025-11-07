Feature: Application controller file has good coverage

  Scenario: Guest sees logged-out header
    When I visit the home page
    Then I should see "Don't have an account? Create one here"
    And I should not see "Log out"

  Scenario: current_user is available after login
    Given a user exists with name "Alice", email "alice_wonderland@tamu.edu", password "wonderland"
    And I am on the login page
    When I log in with email "alice_wonderland@tamu.edu" and password "wonderland"
    Then I should see "Alice"
    And I should see "Logout"

  Scenario: Logout clears the session
    Given a user exists with name "Billy", email "billy@tamu.edu", password "PASSword"
    And I am on the login page
    When I log in with email "billy@tamu.edu" and password "PASSword"
    And I log out
    Then I should see "Welcome back to VinylVerse"


