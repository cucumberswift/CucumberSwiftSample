Feature: Cart
  Shoppers collect products in a cart before they check out.

  Background:
    Given an empty cart

  @Smoke
  Scenario: Add one product
    When I add 1 "Blue Mug"
    Then the cart has 1 item

  Scenario: Add several products from a list
    When I add these products:
      | product   | quantity |
      | Blue Mug  | 2        |
      | Red Plate | 3        |
    Then the cart has 5 items
    And the cart contains "Red Plate"
    But the cart does not contain "Green Bowl"

  Rule: A cart holds at most 10 items

    Scenario: Fill the cart to the limit
      When I add 10 "Blue Mug"
      Then the cart has 10 items

    Scenario: Try to go over the limit
      When I add 10 "Blue Mug"
      And I try to add 1 "Red Plate"
      Then I am told "Your cart is full"
      And the cart has 10 items
