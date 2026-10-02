Feature: Search

  @Smoke
  Scenario: Find a product by name
    Given the catalogue has a product named "Blue Mug"
    When I search for "mug"
    Then I see 1 result

  Scenario: Search with no results
    Given the catalogue has a product named "Blue Mug"
    When I search for "teapot"
    Then I see 0 results
