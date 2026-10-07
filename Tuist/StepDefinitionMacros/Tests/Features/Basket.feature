Feature: A basket of cukes
  Each step is matched by a step definition written as a macro.

  Scenario: Eat some cukes
    Given I have 5 cukes in my "basket"
    When I eat 2 cukes
    Then the basket holds 3 cukes

  Scenario: Eat the cukes listed in a data table
    Given I have 5 cukes in my "basket"
    When I eat these cukes:
      | gherkin |
      | pickle  |
    Then the basket holds 3 cukes
