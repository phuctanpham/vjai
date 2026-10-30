/// How a Gu Match session gets its context (C1).
enum SessionPath {
  /// The user picked a chip or typed text.
  promptLed,

  /// Neither: the context comes from the calendar and location.
  zeroInput,
}
