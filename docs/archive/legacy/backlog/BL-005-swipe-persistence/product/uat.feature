# Owner: APM · Standard: docs/policies/product/bdd.md
Feature: Local swipe persistence and feed filtering

  @BL-005-S01
  Scenario: A swipe is remembered
    Given the user is viewing "usr_01"
    When the user taps "Like"
    Then "usr_01" is stored as swiped
    And the next candidate is shown

  @BL-005-S02
  Scenario: Swiped profiles are filtered on reload
    Given "usr_01" and "usr_02" were swiped earlier
    When the discovery feed loads
    Then the first candidate shown is "usr_03"

  @BL-005-S03
  Scenario: All profiles already swiped
    Given all 5 sample profiles were swiped earlier
    When the discovery feed loads
    Then "You're all caught up!" is shown

  @BL-005-S04
  Scenario: Reset feed history
    Given all profiles were swiped and "You're all caught up!" is shown
    When the user chooses "Reset Feed History"
    Then the swipe history is cleared
    And "usr_01" is shown again

  @BL-005-S05
  Scenario: Storing a swipe fails
    Given local storage cannot be written
    When the user taps "Like" on "usr_01"
    Then an error message is shown
    And "usr_01" is not reported as remembered
# Archived legacy dating BDD; not an active requirement.
