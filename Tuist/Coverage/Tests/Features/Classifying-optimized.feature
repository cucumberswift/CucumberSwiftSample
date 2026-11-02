Feature: Classifying, optimized
  The calculator names a number by its size.

  Background:
    Given a calculator

  # Classifying.feature as a Scenario Outline with a number for each case of classify(_:), so
  # the scenarios run all of its code.
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
