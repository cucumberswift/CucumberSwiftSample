# Role: the AFTER of the coverage warning: add the scenario that is missing.
# Shows: the new scenario divides by zero, which runs the code that the first scenario skips. The
# coverage rises to 90%, above the warning level of 80%.

Feature: Dividing, optimized
  The calculator divides whole numbers.

  Background:
    Given a calculator

  Scenario: Dividing two numbers
    When I divide 6 by 2
    Then the display shows "3"

  Scenario: Dividing by zero
    When I divide 6 by 0
    Then the display shows "You can't divide by zero"
