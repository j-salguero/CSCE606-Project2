Feature: Update Artists

  Background:
    Given the database is clean

  Scenario: Update artist name succeeds
    Given an artist named "Whitney Houston" exists
    When I go to the edit page for artist "Whitney Houston"
    And I fill in "Name" with "Whitney"
    And I press "Update"
    Then I should see "Whitney"

  Scenario: Update artist fails with blank name
    Given an artist named "Adele" exists
    When I view the artist "Adele"
    And I click "Edit this artist"
    And I fill in "Name" with ""
    And I press "Update"
    Then I should see "Name can't be blank"
