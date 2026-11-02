Feature: Dividing, optimized
  The calculator divides whole numbers.

  Background:
    Given a calculator

  # Dividing.feature with a scenario that divides by zero, which runs the code that the first
  # scenario skips. That raises the coverage above the warning level.
  Scenario: Dividing two numbers
    When I divide 6 by 2
    Then the display shows "3"

  Scenario: Dividing by zero
    When I divide 6 by 0
    Then the display shows "You can't divide by zero"
