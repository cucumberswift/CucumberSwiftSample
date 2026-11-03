# Role: the BEFORE of a coverage warning, on purpose.
# Shows: no scenario divides by zero, so the scenarios run 4 of the 6 regions in the functions they
# enter. That is 67%, at or below the warning level of 80%, and the Feature line gets a warning.
# Fix: Dividing-optimized.feature adds a scenario that divides by zero.

Feature: Dividing
  The calculator divides whole numbers.

  Background:
    Given a calculator

  Scenario: Dividing two numbers
    When I divide 6 by 2
    Then the display shows "3"
