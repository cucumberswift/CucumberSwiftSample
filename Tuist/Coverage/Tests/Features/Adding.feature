# Role: the BEFORE of optimization 1, a redundancy error on purpose.
# Shows: 3 scenarios add positive numbers through `add`, which has no branches, so they run the same
# code. 2 of the 4 scenarios are redundant, so the feature's redundancy is 50%, at or above the
# error level of 40% that the scheme sets. The feature fails its Redundancy test, and each
# redundant scenario and each of its When steps gets a warning.
# Fix: Adding-optimized.feature writes the positive numbers as one Scenario Outline.

Feature: Adding
  The calculator adds whole numbers.

  Background:
    Given a calculator

  Scenario: Adding two numbers
    When I add 2 and 3
    Then the display shows "5"

  Scenario: Adding two other numbers
    When I add 4 and 4
    Then the display shows "8"

  Scenario: Adding ones
    When I add 1 and 1
    Then the display shows "2"

  Scenario: Adding two negative numbers
    When I add -2 and -3
    Then the display shows "minus 5"
