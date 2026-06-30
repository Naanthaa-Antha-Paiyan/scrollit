import 'package:flutter/material.dart';

/// A card-based section container for the settings screen.
///
/// Renders a titled group of related settings within a themed [Card].
/// Inspired by Linear/Notion grouped-list sections.
class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...List.generate(children.length * 2 - 1, (i) {
              if (i.isOdd) {
                return const SizedBox(height: 4);
              }
              return children[i ~/ 2];
            }),
          ],
        ),
      ),
    );
  }
}
