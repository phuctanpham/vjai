# Owner: APM · Standard: docs/policies/product/bdd.md
Feature: Discovery feed and adaptive layout

  @BL-004-S01
  Scenario: Feed loads the first candidate
    Given the discovery screen is opened
    When the profiles finish loading
    Then the first candidate's name, age and occupation are shown on the profile card

  @BL-004-S02
  Scenario: Swiping advances to the next candidate
    Given the user is viewing candidate 1 of 5
    When the user taps "Like"
    Then candidate 2 is shown
    And a "like" swipe is recorded for candidate 1

  @BL-004-S03
  Scenario: Swiping the last candidate empties the feed
    Given the user is viewing the last candidate
    When the user taps "Pass"
    Then "You're all caught up!" is shown
    And a "Refresh Feed" button is visible

  @BL-004-S04
  Scenario: Retry after a load error
    Given loading the profiles fails
    Then "Something went wrong" is shown with a "Try Again" button
    When the user taps "Try Again" and loading succeeds
    Then a loading indicator is shown and then the first candidate

  @BL-004-S05
  Scenario: Desktop layout
    Given the window is at least 800 px wide
    When candidates are loaded
    Then the sidebar shows "Discover" and "Matches"
    And the detail panel shows "About <candidate name>"

  @BL-004-S06
  Scenario: Mobile layout
    Given the window is narrower than 800 px
    When candidates are loaded
    Then the profile card fills the width with the Pass, Superlike and Like buttons below it
    And no sidebar is shown
