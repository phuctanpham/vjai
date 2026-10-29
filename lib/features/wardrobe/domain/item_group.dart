/// Top-level wardrobe grouping that drives the Wardrobe chips (C4, P6).
enum ItemGroup {
  tops,
  bottoms,
  shoes,
  bags,
  hats,
  accessories,
}

/// User-facing group labels ("Tops", "Bottoms", …).
extension ItemGroupLabel on ItemGroup {
  String get label => throw UnimplementedError('TASK-003-S07');
}
