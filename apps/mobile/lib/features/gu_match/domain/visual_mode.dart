/// How a Fit's image was made; shown as an honest label (AC-07.2).
enum VisualMode {
  editorialIllustration,
  collageFlatlay,
  virtualTryOn,
}

/// "ILLUSTRATION", "WARDROBE PHOTO", "TRY-ON".
extension VisualModeLabel on VisualMode {
  String get label => switch (this) {
        VisualMode.editorialIllustration => 'ILLUSTRATION',
        VisualMode.collageFlatlay => 'WARDROBE PHOTO',
        VisualMode.virtualTryOn => 'TRY-ON',
      };

  /// Wire value, as in the spec's `visual_mode` enum.
  String get wireName => switch (this) {
        VisualMode.editorialIllustration => 'EDITORIAL_ILLUSTRATION',
        VisualMode.collageFlatlay => 'COLLAGE_FLATLAY',
        VisualMode.virtualTryOn => 'VIRTUAL_TRY_ON',
      };
}
