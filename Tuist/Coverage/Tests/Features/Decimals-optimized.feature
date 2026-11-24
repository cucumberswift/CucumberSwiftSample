# Role: the AFTER of optimization 2: move setup work from each scenario's Given to the Background.
# Shows: `And the display rounds to 2 decimal places` runs once, in the Background. CucumberSwift
# leaves the Background's code out of the redundancy. No step gets a warning, and each scenario
# has only the steps that differ.

Feature: Decimals, optimized
  The calculator rounds a quotient to the decimal places that the display shows.

  Background:
    Given a calculator
    And the display rounds to 2 decimal places

  Scenario: Dividing one by three
    When I get the quotient of 1 and 3
    Then the display shows "0.33"

  Scenario: Dividing minus one by three
    When I get the quotient of -1 and 3
    Then the display shows "minus 0.33"
