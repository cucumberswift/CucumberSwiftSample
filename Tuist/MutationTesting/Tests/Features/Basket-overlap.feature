@after
Feature: Basket, with two scenarios that each check something the other misses
  10% off from 3 items, and free shipping over 100.

  Scenario: Checking out a basket of 100
    Given a basket with items costing 50 and 50
    When I check out
    Then the basket is saved
    And the total is at least 100

  Scenario: A basket of 100 pays shipping
    Given a basket with items costing 50 and 50
    Then the total is 105
