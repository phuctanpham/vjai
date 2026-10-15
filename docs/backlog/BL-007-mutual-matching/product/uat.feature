# Owner: APM · Standard: docs/policies/product/bdd.md
Feature: Mutual match and celebration

  @BL-007-S01
  Scenario Outline: Liking a mutual candidate shows the celebration
    Given the user is viewing "Alex Chen"
    When the user taps "<action>"
    Then "It's a Match!" is shown
    And "You and Alex Chen liked each other." is shown

    Examples:
      | action    |
      | Like      |
      | Superlike |

  @BL-007-S02
  Scenario: Keep swiping
    Given the match celebration is shown
    When the user taps "Keep Swiping"
    Then the celebration closes
    And the next candidate is shown

  @BL-007-S03
  Scenario: Send a message
    Given the match celebration for "Alex Chen" is shown
    When the user taps "Send a Message"
    Then the conversation placeholder for "Alex Chen" is opened

  @BL-007-S04
  Scenario: Non-mutual like
    Given the user is viewing "Elena Rostova"
    When the user taps "Like"
    Then no celebration is shown
    And "Marcus Vance" is shown next

  @BL-007-S05
  Scenario: Pass never matches
    Given the user is viewing "Alex Chen"
    When the user taps "Pass"
    Then no celebration is shown
