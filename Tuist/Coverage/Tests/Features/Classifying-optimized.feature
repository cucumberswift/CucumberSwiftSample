# Role: the AFTER of the coverage error: one Scenario Outline with a row for each case.
# Shows: the 6 examples run every case of `classify(_:)`, so the coverage is 100%. The examples run
# different code, so none is redundant.

Feature: Classifying, optimized
  The calculator names a number by its size.

  Background:
    Given a calculator

  Scenario Outline: Classifying a number
    When I classify <number>
    Then the display shows "<name>"

    Examples:
      | number | name     |
      | -5     | negative |
      | 0      | zero     |
      | 7      | small    |
      | 42     | medium   |
      | 512    | large    |
      | 1000   | huge     |
