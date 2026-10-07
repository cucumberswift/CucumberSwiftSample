Feature: Orders
  Each scenario waits about a second for the warehouse, as a UI test or a test of a
  slow service would. With parallel testing, Xcode runs scenarios in several workers at
  once, so the feature takes less time than its scenarios add up to.

  Background:
    Given the warehouse has these stock levels:
      | product | quantity |
      | mug     | 10       |
      | teapot  | 2        |

  Scenario: Order a product in stock
    When I order 1 "mug"
    Then the order is accepted
    And the warehouse has 9 "mug" in stock

  Scenario: Order the last ones
    When I order 2 "teapot"
    Then the order is accepted
    And the warehouse has 0 "teapot" in stock

  Scenario: Order more than the warehouse has
    When I order 3 "teapot"
    Then the order is rejected
    And the warehouse has 2 "teapot" in stock

  Scenario: Order a product the warehouse doesn't carry
    When I order 1 "kettle"
    Then the order is rejected
