# Role: the BEFORE of optimization 2, redundant steps on purpose.
# Shows: both scenarios start with `Given the display rounds to 2 decimal places`, so the second
# Given step repeats the code of the first. The scenarios themselves are not redundant: one divides
# a positive number and one a negative number, which take different branches in the display. Each
# Given step gets a warning that suggests moving it to the Background.
# Fix: Decimals-optimized.feature sets the decimal places once, in the Background.

Feature: Decimals
  The calculator rounds a quotient to the decimal places that the display shows.

  Background:
    Given a calculator

  Scenario: Dividing one by three
    Given the display rounds to 2 decimal places
    When I get the quotient of 1 and 3
    Then the display shows "0.33"

  Scenario: Dividing minus one by three
    Given the display rounds to 2 decimal places
    When I get the quotient of -1 and 3
    Then the display shows "minus 0.33"
