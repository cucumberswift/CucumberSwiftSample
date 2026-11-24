# Role: the BEFORE of optimization 3, redundant steps on purpose.
# Shows: `When I double 6` and `When I triple 6` have different text, but each keys in the 6 before
# it works on it. Keying in is most of each step's code, so each When step gets a warning that
# suggests moving it to the Background.
# Fix: Doubling-optimized.feature keys the number in once, in the Background, and redefines the
# When steps to work on it.

Feature: Doubling
  The calculator works on the number that you key in.

  Background:
    Given a calculator

  Scenario: Doubling a number
    When I double 6
    Then the display shows "12"

  Scenario: Tripling a number
    When I triple 6
    Then the display shows "18"
