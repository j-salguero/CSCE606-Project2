Feature: User session behavior

  Background:
    Given the database is clean

  Scenario: User logs in successfully
    And a user exists with name "Alice", email "alice@example.com", password "secret123"
    When I am on the login page
    And I log in with email "alice@example.com" and password "secret123"
    Then I should be logged in as username "Alice"

  Scenario: Login fails with wrong password
    And a user exists with name "Bob", email "bob@example.com", password "secret123"
    When I am on the login page
    And I log in with email "bob@example.com" and password "wrongpass"
    Then I should see "Invalid email or password"

  Scenario: User can log out
    Given I visit the home page
    And a user exists with name "Carol", email "carol@example.com", password "pass789"
    And I log out
    Then I should see "Don't have an account? Create one here"
