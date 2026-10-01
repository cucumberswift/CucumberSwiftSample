Feature: Account

  Scenario Outline: Sign up with a password
    Given I sign up with the password "<password>"
    Then my password is <verdict>

    Examples: Strong passwords
      | password         | verdict  |
      | correct-horse-42 | accepted |
      | Tr0ub4dor&3xyz   | accepted |

    Examples: Weak passwords
      | password | verdict  |
      | 1234     | rejected |
      | password | rejected |

  Scenario: Read the terms before signing up
    Given the terms say:
      """
      Be kind.
      Pay for what you order.
      """
    Then the terms have 2 lines
