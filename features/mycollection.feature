Feature: My Collection functionality

  Background:
    Given the database is clean

  Scenario: Collection page renders
    When I go to the collection page
    Then I should see "Collection"
    And I should see "My Collection"

  Scenario: Collection shows a seeded item
    Given a collection item "Abbey Road" by "The Beatles" exists
    When I go to the collection page
    Then I should see "Abbey Road"
    And I should see "The Beatles"

  Scenario: Collection shows multiple seeded items
    Given a collection item "Rumours" by "Fleetwood Mac" exists
    And a collection item "Purple Rain" by "Prince" exists
    When I go to the collection page
    Then I should see "Rumours"
    And I should see "Purple Rain"

  Scenario: Add an album with no artist → uses Unknown Artist and no year
    When I visit "/collection_items"
    And I post to "/collection_items" with:
      | release[title] | MysteryRecord |
    Then I should be on "/collection_items"
    And I should see "Unknown Artist"

  Scenario: Adding the same album twice shows duplicate message
    When I post to "/collection_items" with:
      | release[title] | MysteryRecord |
    And I post to "/collection_items" with:
      | release[title] | MysteryRecord |
    Then I should be on "/collection_items"
    And I should see "already in your collection"

  Scenario: Updating album image when adding again
    Given the database is clean
    And an artist named "Unknown Artist" exists
    And an album titled "Ghost Album" by "Unknown Artist" exists without image
    When I send a collection POST request to "/collection_items" with:
        | release[title] | Ghost Album |
        | release[thumb] | http://example.com/image.jpg |
    Then I should be on "/collection_items"
    And I should see "Unknown Artist"

  Scenario: Cannot add an album that is already in collection
    Given the database is clean
    And an artist named "Nirvana" exists
    And an album titled "Nevermind" by "Nirvana" exists
    And a collection item for "Nevermind" exists
    When I send a collection POST request to "/collection_items" with:
        | release[title] | Nevermind |
        | release[artist] | Nirvana |
    Then I should be on "/collection_items"
    And I should see "already in your collection"

  Scenario: Adding increases collection count
    When I go to the collection page
    And I note the collection count
    And I add any album to my collection
    Then the collection count should increase by 1

  Scenario: Removing decreases collection count
    When I go to the collection page
    And I add any album to my collection
    And I note the collection count
    And I remove any album from my collection
    Then the collection count should decrease by 1

  Scenario: Destroy removes an item and shows a notice
    Given a collection item "Selfish Machines" by "Pierce The Veil" exists
    When I visit "/collection_items"
    And I click the first "Remove from Collection" link
    Then I should be on the collection page
    And I should see "Selfish Machines removed from your collection"


