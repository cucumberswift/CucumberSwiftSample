Feature: Profile menu
  The profile menu shows the user's details.

  Background:
    Given the user is logged in

  # Redundant steps: both When steps open the profile menu before they show an item, so most of
  # each step's code is repeated by the other. ProfileMenu-optimized.feature opens the menu in the
  # Background instead.
  Scenario: View the username
    When I click my user profile
    Then I should see my username

  Scenario: View the balance
    When I click my account
    Then I should see my balance
