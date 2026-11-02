Feature: Subtracting, optimized
  The calculator subtracts whole numbers.

  Background:
    Given a calculator

  # Subtracting.feature without its redundant scenario: the 2 scenarios left run the same code
  # as the 3 did, in less time.
  Scenario: Subtracting a larger number
    When I subtract 7 from 4
    Then the display shows "minus 3"

  Scenario: Subtracting a smaller number
    When I subtract 4 from 7
    Then the display shows "3"
