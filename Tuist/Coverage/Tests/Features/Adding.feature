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
