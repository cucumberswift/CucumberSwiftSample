Feature: Subtracting
  The calculator subtracts whole numbers.

  Background:
    Given a calculator

  # A redundancy warning: the last scenario runs the same code as the first, so 1 of the 3
  # scenarios is redundant. That is 33%, at or above the warning level of 30%.
  Scenario: Subtracting a larger number
    When I subtract 7 from 4
    Then the display shows "minus 3"

  Scenario: Subtracting a smaller number
    When I subtract 4 from 7
    Then the display shows "3"

  Scenario: Subtracting another larger number
    When I subtract 9 from 1
    Then the display shows "minus 8"
