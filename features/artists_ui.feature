Feature: Artists UI extras

  Background:
    Given the database is clean

  Scenario: Artists index shows empty state
    When I go to the artists page
    Then I should see "No artists found yet"
