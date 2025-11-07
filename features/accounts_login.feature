Feature: User login works as expected

  Background:
    Given the database is clean

  Scenario: User logs in successfully
    And a user exists with name "Jane", email "janedoe@tamu.edu", password "password123"
    When I am on the login page
    And I log in with email "janedoe@tamu.edu" and password "password123"
    Then I should be logged in as username "Jane"

  Scenario: Login fails with wrong password
    And a user exists with name "Bob", email "bob@tamu.edu", password "321password"
    When I am on the login page
    And I log in with email "bob@tamu.edu" and password "incorrect"
    Then I should see "Invalid email or password"

  Scenario: User can log out
    Given I visit the home page
    And a user exists with name "MaryJane", email "maryjane@tamu.edu", password "pass123word"
    And I log out
    Then I should see "Don't have an account? Create one here"

  Scenario: Login with empty fields reloads page
    Given I am on the login page
    And I press "Login"
    Then I should see "Invalid email or password"
    And I should see "Welcome Back to VinylVerse"

  Scenario: User logs in and then logs out
    Given a user exists with name "Dora", email "dora@tamu.edu", password "pass123"
    And I am on the login page
    And I fill in "Email" with "dora@example.com"
    And I fill in "Password" with "pass123"
    And I press "Log in"
    When I click "Logout"
    Then I should see "You have been logged out"
    And I should not see "Dora"
