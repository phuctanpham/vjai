# Owner: APM · Standard: docs/policies/product/bdd.md
# No UI changes: Then-steps assert the repository contract (bdd.md rule 3).
Feature: Backend discovery API integration

  @BL-006-S01
  Scenario: Candidates load from the server
    Given the mock server is running
    When the discovery feed loads
    Then the candidates are the server's sample profiles, starting with "Alex Chen"

  @BL-006-S02
  Scenario: A swipe is sent to the server
    Given "usr_01" is the current candidate
    When the user taps "Like"
    Then the server receives a swipe with profileId "usr_01" and swipeType "like"

  @BL-006-S03
  Scenario: Server error is shown
    Given the server answers with status 500
    When the discovery feed loads
    Then "Something went wrong" is shown with a "Try Again" button

  @BL-006-S04
  Scenario: Offline fallback
    Given the server cannot be reached
    When the discovery feed loads
    Then the sample profiles are shown
    And a fallback warning is logged
# Archived legacy dating BDD; not an active requirement.
