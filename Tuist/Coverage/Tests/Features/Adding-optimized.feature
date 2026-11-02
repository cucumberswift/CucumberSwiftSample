Feature: Adding, optimized
  The calculator adds whole numbers.

  Background:
    Given a calculator

  # Adding.feature with no redundancy: one Scenario Outline replaces the 3 scenarios that add
  # positive numbers, and its examples count as one scenario.
  Scenario Outline: Adding positive numbers
    When I add <first> and <second>
    Then the display shows "<sum>"

    Examples:
      | first | second | sum |
      | 2     | 3      | 5   |
      | 4     | 4      | 8   |
      | 1     | 1      | 2   |

  Scenario: Adding two negative numbers
    When I add -2 and -3
    Then the display shows "minus 5"
