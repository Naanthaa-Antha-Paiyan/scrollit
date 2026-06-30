import 'package:flutter/material.dart';

/// Font weight options for reader text.
enum FontWeightOption {
  normal(FontWeight.w400, 'Normal'),
  medium(FontWeight.w500, 'Medium'),
  semiBold(FontWeight.w600, 'Semi Bold'),
  bold(FontWeight.w700, 'Bold'),
  extraBold(FontWeight.w800, 'Extra Bold');

  const FontWeightOption(this.weight, this.label);
  final FontWeight weight;
  final String label;

  /// Persistence key (enum name).
  String get key => name;

  static FontWeightOption fromKey(String? key) {
    if (key == null) return FontWeightOption.normal;
    return FontWeightOption.values.firstWhere(
      (e) => e.name == key,
      orElse: () => FontWeightOption.normal,
    );
  }
}

/// Text color presets for the reader.
enum TextColorOption {
  pureWhite(Color(0xFFFFFFFF), 'Pure White'),
  softWhite(Color(0xFFF0F0F0), 'Soft White'),
  lightGray(Color(0xFFDADADA), 'Light Gray'),
  warmWhite(Color(0xFFFFF4E8), 'Warm White');

  const TextColorOption(this.color, this.label);
  final Color color;
  final String label;

  String get key => name;

  static TextColorOption fromKey(String? key) {
    if (key == null) return TextColorOption.pureWhite;
    return TextColorOption.values.firstWhere(
      (e) => e.name == key,
      orElse: () => TextColorOption.pureWhite,
    );
  }
}

/// How far arrow up/down moves the scroll position (as a ratio of total extent).
enum ManualScrollStep {
  small(0.01, 'Small'),
  medium(0.02, 'Medium'),
  large(0.04, 'Large');

  const ManualScrollStep(this.delta, this.label);
  final double delta;
  final String label;

  String get key => name;

  static ManualScrollStep fromKey(String? key) {
    if (key == null) return ManualScrollStep.medium;
    return ManualScrollStep.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ManualScrollStep.medium,
    );
  }
}

/// Page Up / Page Down jump distance as a fraction of the scroll extent.
enum PageJumpSize {
  five(0.05, '5%'),
  ten(0.10, '10%'),
  fifteen(0.15, '15%'),
  twenty(0.20, '20%');

  const PageJumpSize(this.fraction, this.label);
  final double fraction;
  final String label;

  String get key => name;

  static PageJumpSize fromKey(String? key) {
    if (key == null) return PageJumpSize.fifteen;
    return PageJumpSize.values.firstWhere(
      (e) => e.name == key,
      orElse: () => PageJumpSize.fifteen,
    );
  }
}

/// Teleprompter optimization presets.
enum OptimizationPreset {
  standard('Standard', 'No changes applied'),
  bold('Bold', 'Increases font weight for better visibility'),
  highContrast('High Contrast', 'Bright white text for maximum readability'),
  ghostReduction('Ghost Reduction', 'Reduces double reflections on glass');

  const OptimizationPreset(this.label, this.description);
  final String label;
  final String description;

  String get key => name;

  static OptimizationPreset fromKey(String? key) {
    if (key == null) return OptimizationPreset.standard;
    return OptimizationPreset.values.firstWhere(
      (e) => e.name == key,
      orElse: () => OptimizationPreset.standard,
    );
  }
}
