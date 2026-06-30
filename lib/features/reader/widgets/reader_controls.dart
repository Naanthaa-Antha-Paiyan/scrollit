import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/app_settings_provider.dart';
import '../providers/reader_provider.dart';

class ReaderControls extends ConsumerWidget {
  const ReaderControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final reader = ref.watch(readerProvider);

    return Listener(
      onPointerDown: (_) =>
          ref.read(readerProvider.notifier).showControlsTemporarily(),
      onPointerMove: (_) =>
          ref.read(readerProvider.notifier).showControlsTemporarily(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSliderRow(
                  context,
                  icon: Icons.text_fields,
                  label: 'Size',
                  value: settings.fontSize,
                  min: AppSettings.minFontSize,
                  max: AppSettings.maxFontSize,
                  displayValue: '${settings.fontSize.round()}',
                  onChanged: (v) =>
                      ref.read(appSettingsProvider.notifier).setFontSize(v),
                ),
                const SizedBox(height: 4),
                _buildSliderRow(
                  context,
                  icon: Icons.speed,
                  label: 'Speed',
                  value: settings.scrollSpeed,
                  min: AppSettings.minScrollSpeed,
                  max: AppSettings.maxScrollSpeed,
                  displayValue: settings.scrollSpeed.toStringAsFixed(1),
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .setScrollSpeed(v),
                ),
                const SizedBox(height: 4),
                _buildSliderRow(
                  context,
                  icon: Icons.horizontal_distribute,
                  label: 'Padding',
                  value: settings.horizontalPadding,
                  min: AppSettings.minHorizontalPadding,
                  max: AppSettings.maxHorizontalPadding,
                  displayValue: '${settings.horizontalPadding.round()}',
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .setHorizontalPadding(v),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToggleButton(
                      context,
                      icon: reader.isAutoScrolling
                          ? Icons.pause
                          : Icons.play_arrow,
                      label: reader.isAutoScrolling ? 'Pause' : 'Auto',
                      active: reader.isAutoScrolling,
                      onPressed: () =>
                          ref.read(readerProvider.notifier).toggleAutoScroll(),
                    ),
                    _buildToggleButton(
                      context,
                      icon: Icons.flip_to_front,
                      label: 'Mirror',
                      active: settings.mirrorMode,
                      onPressed: () => ref
                          .read(appSettingsProvider.notifier)
                          .toggleMirrorMode(),
                    ),
                    _buildToggleButton(
                      context,
                      icon: Icons.fullscreen,
                      label: 'Fullscreen',
                      active: reader.isFullscreen,
                      onPressed: () =>
                          ref.read(readerProvider.notifier).toggleFullscreen(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.white,
              overlayColor: Color(0x29FFFFFF),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            displayValue,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: active ? Colors.white : Colors.white54,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontSize: 12,
        ),
      ),
    );
  }
}
