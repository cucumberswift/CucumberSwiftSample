Feature: Memory
  The calculator keeps numbers in memory.

  Background:
    Given a calculator

  Scenario: Reading the memory
    When I read the memory
    Then the display shows "0"

  Scenario: Clearing the memory
    When I clear the memory
    Then the display shows "3"
