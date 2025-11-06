Feature: Sign Up page works
  Scenario: Sign up page loads
    Given the database is clean
    And I am on the signup page
    Then I should see "Join VinylVerse"
    And I should see "Confirm Password"

  Scenario: Sign up fails when name is missing
    Given the database is clean
    And I am on the signup page
    When I fill in "Email" with "test@tamu.edu"
    And I fill in "Password" with "pass123"
    And I fill in "Confirm Password" with "pass123"
    And I press "Create Account"
    Then I should see "Name can't be blank"

Scenario: Sign up fails when passwords do not match
  Given the database is clean
  And I am on the signup page
  When I fill in "Name" with "NoMatch"
  And I fill in "Email" with "nomatch@tamu.edu"
  And I fill in "Password" with "abc123"
  And I fill in "Confirm Password" with "somethingelse"
  And I press "Create Account"
  Then I should see "Password confirmation doesn't match"

