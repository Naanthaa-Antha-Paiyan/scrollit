import 'package:flutter/material.dart';

/// A settings row with a label, optional subtitle, and a [Switch].
class SettingsToggleTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? badge;

  const SettingsToggleTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    badge!,
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
