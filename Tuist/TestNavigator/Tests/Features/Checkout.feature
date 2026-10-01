Feature: Checkout

  @Smoke @Checkout
  Scenario: Pay with a saved card
    Given a cart with 2 items
    When I pay with my saved card
    Then the order total is 20

  @Checkout
  Scenario: Pay with a gift card
    Given a cart with 1 item
    When I pay with a gift card
    Then the order total is 10

  @Checkout
  Scenario Outline: Sign in before paying
    Given a user <email> with role <role>
    When they sign in
    Then they can pay

    # The last two rows are the same, to show how a repeated example is named.
    Examples:
      | email       | role     |
      | bob@x.com   | admin    |
      | amy@x.com   | customer |
      | amy@x.com   | customer |

  # This scenario is skipped on purpose: its second step throws XCTSkip.
  @Checkout
  Scenario: Pay at the card terminal
    Given a cart with 2 items
    And the card terminal is offline
    When I pay with my saved card
    Then the order total is 20

  # This scenario fails on purpose, to show where Xcode reports a failing step.
  # See "The failing scenario" in README.md.
  @Checkout
  Scenario: Apply a discount code
    Given a cart with 2 items
    When I apply the discount code "SAVE10"
    Then the order total is 18
    And I see the discount "SAVE10"
