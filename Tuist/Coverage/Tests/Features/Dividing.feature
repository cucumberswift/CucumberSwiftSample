Feature: Dividing
  The calculator divides whole numbers.

  Background:
    Given a calculator

  # A coverage warning: the scenario runs 67% of the code in the functions it enters, at or below
  # the warning level of 80%. No scenario divides by zero, as Dividing-optimized.feature does.
  Scenario: Dividing two numbers
    When I divide 6 by 2
    Then the display shows "3"
