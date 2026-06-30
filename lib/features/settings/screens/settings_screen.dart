import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../models/reader_enums.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/color_picker_row.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_slider_tile.dart';
import '../widgets/settings_toggle_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Reader Section ───────────────────────────────────────
          SettingsSection(
            title: 'Reader',
            children: [
              SettingsSliderTile(
                label: 'Font Size',
                value: settings.fontSize,
                min: AppSettings.minFontSize,
                max: AppSettings.maxFontSize,
                divisions: (AppSettings.maxFontSize - AppSettings.minFontSize)
                    .round(),
                displayValue: '${settings.fontSize.round()}',
                onChanged: notifier.setFontSize,
              ),
              _buildSegmentedRow<FontWeightOption>(
                context,
                label: 'Font Weight',
                options: FontWeightOption.values,
                selected: settings.fontWeight,
                labelOf: (o) => o.label,
                onChanged: notifier.setFontWeight,
              ),
              SettingsSliderTile(
                label: 'Horizontal Padding',
                value: settings.horizontalPadding,
                min: AppSettings.minHorizontalPadding,
                max: AppSettings.maxHorizontalPadding,
                divisions:
                    (AppSettings.maxHorizontalPadding -
                            AppSettings.minHorizontalPadding)
                        .round(),
                displayValue: '${settings.horizontalPadding.round()}',
                onChanged: notifier.setHorizontalPadding,
              ),
              SettingsSliderTile(
                label: 'Line Height',
                value: settings.lineHeight,
                min: AppSettings.minLineHeight,
                max: AppSettings.maxLineHeight,
                divisions: 20,
                displayValue: settings.lineHeight.toStringAsFixed(1),
                onChanged: notifier.setLineHeight,
              ),
              SettingsSliderTile(
                label: 'Letter Spacing',
                value: settings.letterSpacing,
                min: AppSettings.minLetterSpacing,
                max: AppSettings.maxLetterSpacing,
                divisions: 50,
                displayValue: settings.letterSpacing.toStringAsFixed(1),
                onChanged: notifier.setLetterSpacing,
              ),
              ColorPickerRow(
                selected: settings.textColor,
                onChanged: notifier.setTextColor,
              ),
              SettingsToggleTile(
                label: 'Mirror Mode',
                subtitle: 'Flip text horizontally for teleprompter glass',
                value: settings.mirrorMode,
                onChanged: (_) => notifier.toggleMirrorMode(),
              ),
            ],
          ),

          // ── Scrolling Section ────────────────────────────────────
          SettingsSection(
            title: 'Scrolling',
            children: [
              SettingsSliderTile(
                label: 'Scroll Speed',
                value: settings.scrollSpeed,
                min: AppSettings.minScrollSpeed,
                max: AppSettings.maxScrollSpeed,
                divisions:
                    ((AppSettings.maxScrollSpeed - AppSettings.minScrollSpeed) *
                            10)
                        .round(),
                displayValue: '${settings.scrollSpeed.toStringAsFixed(1)}x',
                onChanged: notifier.setScrollSpeed,
              ),
              _buildSegmentedRow<ManualScrollStep>(
                context,
                label: 'Manual Scroll Step',
                options: ManualScrollStep.values,
                selected: settings.manualScrollStep,
                labelOf: (o) => o.label,
                onChanged: notifier.setManualScrollStep,
              ),
              _buildSegmentedRow<PageJumpSize>(
                context,
                label: 'Page Jump Size',
                options: PageJumpSize.values,
                selected: settings.pageJumpSize,
                labelOf: (o) => o.label,
                onChanged: notifier.setPageJumpSize,
              ),
            ],
          ),

          // ── Teleprompter Optimization Section ────────────────────
          SettingsSection(
            title: 'Teleprompter Optimization',
            subtitle:
                'Improve readability on DIY teleprompters with ghosting or double reflections.',
            children: [
              _buildSegmentedRow<OptimizationPreset>(
                context,
                label: 'Optimization Preset',
                options: OptimizationPreset.values,
                selected: settings.optimizationPreset,
                labelOf: (o) => o.label,
                onChanged: notifier.setOptimizationPreset,
              ),
              if (settings.optimizationPreset != OptimizationPreset.standard)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    settings.optimizationPreset.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              SettingsToggleTile(
                label: 'Ghost Reduction Overlay',
                subtitle: 'Experimental rendering overlay for ghost reduction',
                value: settings.ghostReductionOverlay,
                onChanged: (_) => notifier.toggleGhostReductionOverlay(),
                badge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BETA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Remote Control Section ───────────────────────────────
          SettingsSection(
            title: 'Remote Control',
            children: [
              SettingsToggleTile(
                label: 'Show Last Key Received',
                subtitle: 'Display a debug overlay showing the last key press',
                value: settings.showLastKeyReceived,
                onChanged: (_) => notifier.toggleShowLastKeyReceived(),
              ),
              SettingsToggleTile(
                label: 'Show Remote Debug Info',
                subtitle:
                    'Show last key, auto-scroll state, and speed in reader',
                value: settings.showRemoteDebugInfo,
                onChanged: (_) => notifier.toggleShowRemoteDebugInfo(),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds a labeled row with a [SegmentedButton] for enum-based options.
  Widget _buildSegmentedRow<T extends Enum>(
    BuildContext context, {
    required String label,
    required List<T> options,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: options
                .map((o) => ButtonSegment<T>(
                      value: o,
                      label: Text(
                        labelOf(o),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ))
                .toList(),
            selected: {selected},
            onSelectionChanged: (set) => onChanged(set.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
