Feature: Classifying
  The calculator names a number by its size.

  Background:
    Given a calculator

  # A coverage error, which fails this feature on purpose: the scenario runs 44% of classify(_:),
  # at or below the error level of 50%.
  Scenario: Classifying a small number
    When I classify 7
    Then the display shows "small"
