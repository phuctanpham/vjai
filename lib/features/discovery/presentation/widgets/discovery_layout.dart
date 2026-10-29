import 'package:flutter/material.dart';
import '../../domain/profile.dart';
import '../../domain/swipe_type.dart';
import 'profile_card.dart';

/// Callback signature for user swipe actions.
typedef OnSwipeCallback = void Function(SwipeType type);

/// Responsive layout for the discovery view adapting to available width.
class DiscoveryLayout extends StatelessWidget {
  final Profile profile;
  final OnSwipeCallback onSwipe;
  final int remainingCount;

  /// Breakpoint above which desktop layout is activated.
  static const double desktopBreakpoint = 800.0;

  const DiscoveryLayout({
    super.key,
    required this.profile,
    required this.onSwipe,
    this.remainingCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          return _buildDesktopLayout(context, constraints);
        }
        return _buildMobileLayout(context, constraints);
      },
    );
  }

  /// Mobile-first touch-friendly card layout.
  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Expanded(
              child: ProfileCard(profile: profile),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, isCompact: false),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Desktop layout with sidebar, centered card, and detailed info panel.
  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
        // Desktop navigation sidebar
        _buildDesktopSidebar(context),

        const VerticalDivider(width: 1, thickness: 1),

        // Main content area: centered card with controls
        Expanded(
          flex: 5,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
                maxHeight: 700,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ProfileCard(profile: profile),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(context, isCompact: false),
                  ],
                ),
              ),
            ),
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Right details panel
        Expanded(
          flex: 4,
          child: _buildDesktopInfoPanel(context),
        ),
      ],
    );
  }

  /// Action buttons (Pass, Superlike, Like).
  Widget _buildActionButtons(BuildContext context, {required bool isCompact}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pass button
        _ActionButton(
          icon: Icons.close_rounded,
          color: Colors.redAccent,
          tooltip: 'Pass',
          size: isCompact ? 50 : 64,
          onPressed: () => onSwipe(SwipeType.pass),
        ),
        const SizedBox(width: 20),

        // Superlike button
        _ActionButton(
          icon: Icons.star_rounded,
          color: Colors.blueAccent,
          tooltip: 'Superlike',
          size: isCompact ? 44 : 54,
          onPressed: () => onSwipe(SwipeType.superlike),
        ),
        const SizedBox(width: 20),

        // Like button
        _ActionButton(
          icon: Icons.favorite_rounded,
          color: Colors.greenAccent.shade700,
          tooltip: 'Like',
          size: isCompact ? 50 : 64,
          onPressed: () => onSwipe(SwipeType.like),
        ),
      ],
    );
  }

  /// Desktop sidebar navigation.
  Widget _buildDesktopSidebar(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 240,
      child: Material(
        color: theme.colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Garblo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.explore_rounded),
              title: const Text('Discover'),
              selected: true,
              selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded),
              title: const Text('Matches'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('Messages'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profile'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop profile info panel.
  Widget _buildDesktopInfoPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(28.0),
        children: [
          Text(
            'About ${profile.name}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (profile.bio.isNotEmpty) ...[
            Text(
              profile.bio,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildInfoRow(
            theme,
            Icons.work_outline_rounded,
            'Occupation',
            profile.occupation.isNotEmpty ? profile.occupation : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            theme,
            Icons.location_on_outlined,
            'Distance',
            '${profile.distanceKm} km away',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            theme,
            Icons.cake_outlined,
            'Age',
            '${profile.age} years old',
          ),
          const SizedBox(height: 24),
          if (profile.interests.isNotEmpty) ...[
            Text(
              'Interests & Passions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.interests.map((interest) {
                return Chip(
                  label: Text(interest),
                  backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final double size;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
