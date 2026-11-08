@before
Feature: Basket
  10% off from 3 items, and free shipping over 100.

  Scenario: Two items pay shipping
    Given a basket with items costing 20 and 30
    Then the total is 55

  Scenario: Three items get a discount
    Given a basket with items costing 50, 50 and 50
    Then the total is 135

  Scenario: Checking out saves the basket
    Given a basket with items costing 20 and 30
    When I check out
    Then the basket is saved
