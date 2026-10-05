Feature: Shipping
  Orders of up to 5 items go by post, larger ones by courier.

  Background:
    Given the warehouse has 20 "mug"

  Scenario: Ship one item by post
    When I order 1 "mug"
    Then the order ships by "post"

  Scenario: Ship five items by post
    When I order 5 "mug"
    Then the order ships by "post"

  Scenario: Ship six items by courier
    When I order 6 "mug"
    Then the order ships by "courier"

  Scenario: Ship the whole stock by courier
    When I order 20 "mug"
    Then the order ships by "courier"
    And the warehouse has 0 "mug" in stock
