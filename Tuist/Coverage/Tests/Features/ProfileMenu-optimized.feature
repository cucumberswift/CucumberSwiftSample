Feature: Profile menu, optimized
  The profile menu shows the user's details.

  # ProfileMenu.feature with the menu opened in the Background, which the redundancy leaves out.
  # Each When step runs only the code that shows its item, so no step is redundant.
  Background:
    Given the user is logged in
    And the user's profile menu is open

  Scenario: View the username
    When I view my user profile
    Then I should see my username

  Scenario: View the balance
    When I view my account
    Then I should see my balance
