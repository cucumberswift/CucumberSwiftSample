Feature: Arithmetic
  The calculator adds, subtracts and divides whole numbers.

  Scenario: Adding two numbers
    Given a calculator
    When I add 2 and 3
    Then the display shows "5"

  Scenario: Subtracting a larger number
    Given a calculator
    When I subtract 7 from 4
    Then the display shows "minus 3"

  Scenario: Dividing by zero
    Given a calculator
    When I divide 1 by 0
    Then the display shows "You can't divide by zero"
