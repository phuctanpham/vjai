import 'package:flutter/material.dart';

import '../../domain/dormancy.dart';
import '../../domain/item_group.dart';
import '../../domain/wardrobe_item.dart';

/// Archive cell (spec T7 › G2): image or placeholder, name,
/// "{Group} · {Style}", and the BENCHED status at 30+ days (I8).
class WardrobeItemCard extends StatelessWidget {
  final WardrobeItem item;
  final int daysUnworn;

  const WardrobeItemCard({
    super.key,
    required this.item,
    required this.daysUnworn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = DormancyRules.badgeLabel(daysUnworn);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainer,
                    child: Icon(
                      Icons.checkroom_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.group.label} · ${item.styleTag}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
