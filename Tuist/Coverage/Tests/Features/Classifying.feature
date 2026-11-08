# Role: the BEFORE of a coverage error, on purpose.
# Shows: one scenario classifies one number, so it runs 4 of the 9 regions in `classify(_:)`. That
# is 44%, at or below the error level of 50% that the scheme sets. The feature fails its Coverage
# test, and the message names `classify(_:)` as the code that no scenario ran.
# Fix: Classifying-optimized.feature classifies a number for each case.

Feature: Classifying
  The calculator names a number by its size.

  Background:
    Given a calculator

  Scenario: Classifying a small number
    When I classify 7
    Then the display shows "small"
