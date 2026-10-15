# Owner: APM · Standard: docs/policies/product/bdd.md
Feature: Authentication and session

  @BL-002-S01
  Scenario: Successful sign-in
    Given the user is on the sign-in screen
    When the user enters "alex@example.com" and "password123" and taps "Sign In"
    Then a progress indicator is shown on the button
    And then the discovery feed is shown
    And the session is kept on the device

  @BL-002-S02
  Scenario: Invalid email is rejected before submitting
    Given the user is on the sign-in screen
    When the user enters "not-an-email" and taps "Sign In"
    Then "Please enter a valid email address" is shown
    And no sign-in request is sent

  @BL-002-S03
  Scenario: Short password is rejected before submitting
    Given the user is on the sign-in screen
    When the user enters "alex@example.com" and "12345" and taps "Sign In"
    Then "Password must be at least 6 characters" is shown
    And no sign-in request is sent

  @BL-002-S04
  Scenario: Wrong credentials
    Given the user is on the sign-in screen
    When the user enters "alex@example.com" and "wrong-password" and taps "Sign In"
    Then "Invalid email or password" is shown
    And the "Sign In" button is enabled again

  @BL-002-S05
  Scenario: Session survives a restart
    Given the user signed in earlier
    When the app starts
    Then the discovery feed is shown without the sign-in screen

  @BL-002-S06
  Scenario: Signed-out user is sent to sign-in
    Given no session exists
    When the app starts
    Then the sign-in screen is shown

  @BL-002-S07
  Scenario: Sign out
    Given the user is signed in
    When the user signs out
    Then the session is removed from the device
    And the sign-in screen is shown

  @BL-002-S08
  Scenario: Mock social sign-in
    Given the user is on the sign-in screen
    When the user taps "Continue with Google"
    Then the discovery feed is shown

  @BL-002-S09
  Scenario Outline: Sign-in form layout
    Given the window is <width> px wide
    When the sign-in screen is shown
    Then the form is <layout>

    Examples:
      | width | layout                          |
      | 400   | full width                      |
      | 1280  | a centred card at most 420 wide |
