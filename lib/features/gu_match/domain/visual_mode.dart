/// How a look's image was made; shown as an honest label (AC-07.2).
enum VisualMode {
  editorialIllustration,
  collageFlatlay,
  virtualTryOn,
}

/// "ILLUSTRATION", "WARDROBE PHOTO", "TRY-ON".
extension VisualModeLabel on VisualMode {
  String get label => throw UnimplementedError('TASK-004-S04');
}
