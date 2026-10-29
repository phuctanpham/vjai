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
  String get label => switch (this) {
        Occasion.work => 'Work',
        Occasion.coffee => 'Coffee',
        Occasion.afternoonRain => 'Afternoon rain',
        Occasion.date => 'Date',
        Occasion.weekendOuting => 'Weekend outing',
      };
}
