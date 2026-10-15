# Owner: APM · Standard: docs/policies/product/bdd.md
Feature: Matches and connections view

  @BL-008-S01
  Scenario: No matches yet
    Given the user has no matches
    When the matches screen opens
    Then "No matches yet!" is shown
    When the user taps "Start Swiping"
    Then the discovery feed is shown

  @BL-008-S02
  Scenario: Matches are listed
    Given the user has matched with "Alex Chen" and "David Kim"
    When the matches screen opens
    Then the "New Matches" carousel shows 2 avatars
    And the list shows "Alex Chen" and "David Kim"

  @BL-008-S03
  Scenario: Search by name
    Given the list shows "Alex Chen" and "David Kim"
    When the user types "alex" in the search field
    Then only "Alex Chen" is listed

  @BL-008-S04
  Scenario: Loading matches fails
    Given loading matches fails
    When the matches screen opens
    Then "Something went wrong" is shown with a "Try Again" button
    When the user taps "Try Again" and loading succeeds
    Then the matches are listed

  @BL-008-S05
  Scenario: Open a match
    Given the list shows "Alex Chen"
    When the user taps "Alex Chen"
    Then the conversation placeholder for "Alex Chen" is opened
