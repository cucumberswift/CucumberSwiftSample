# Role: the AFTER of optimization 3: move the repeated work after the setup to the Background.
# Shows: `And the number 6 is entered` is a Background step next to `Given a calculator`. The When
# steps are now `I double it` and `I triple it`, which only work on the number, so no step is
# redundant.

Feature: Doubling, optimized
  The calculator works on the number that you key in.

  Background:
    Given a calculator
    And the number 6 is entered

  Scenario: Doubling a number
    When I double it
    Then the display shows "12"

  Scenario: Tripling a number
    When I triple it
    Then the display shows "18"
