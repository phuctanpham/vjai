/// Top-level wardrobe grouping that drives the Archive chips (C4, P6).
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
  String get label => switch (this) {
        ItemGroup.tops => 'Tops',
        ItemGroup.bottoms => 'Bottoms',
        ItemGroup.shoes => 'Shoes',
        ItemGroup.bags => 'Bags',
        ItemGroup.hats => 'Hats',
        ItemGroup.accessories => 'Accessories',
      };
}
