/// Occasion chips on the styling studio; multi-select (C10).
enum Occasion {
  work,
  coffee,
  afternoonRain,
  date,
  weekendOuting,
}

/// User-facing labels ("Work", "Coffee", "Afternoon rain", …).
extension OccasionLabel on Occasion {
  String get label => throw UnimplementedError('TASK-004-S02');
}
