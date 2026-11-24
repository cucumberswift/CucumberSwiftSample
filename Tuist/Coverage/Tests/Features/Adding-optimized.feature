# Role: the AFTER of optimization 1: reduce similar scenarios to one Scenario Outline.
# Shows: Adding.feature's 3 scenarios are now the rows of one Scenario Outline, and an outline's
# examples count as one scenario. Redundancy drops from 50% to 0% and no step gets a warning. The
# negative numbers stay a scenario of their own, because they run different code.

Feature: Adding, optimized
  The calculator adds whole numbers.

  Background:
    Given a calculator

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
