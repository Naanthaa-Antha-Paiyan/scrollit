import 'package:flutter/material.dart';
import 'reader_enums.dart';

/// Unified, immutable settings model for the entire app.
///
/// Replaces the old `ReaderSettings` with a single class covering
/// reader appearance, scrolling behaviour, teleprompter optimisation,
/// and remote-control preferences.
class AppSettings {
  // ── Reader Appearance ──────────────────────────────────────────────
  final double fontSize;
  final FontWeightOption fontWeight;
  final double horizontalPadding;
  final double lineHeight;
  final double letterSpacing;
  final TextColorOption textColor;
  final bool mirrorMode;
  final OptimizationPreset optimizationPreset;

  // ── Scrolling ──────────────────────────────────────────────────────
  final double scrollSpeed;
  final ManualScrollStep manualScrollStep;
  final PageJumpSize pageJumpSize;

  // ── Teleprompter ───────────────────────────────────────────────────
  final bool ghostReductionOverlay;

  // ── Remote Control ─────────────────────────────────────────────────
  final bool showLastKeyReceived;
  final bool showRemoteDebugInfo;

  const AppSettings({
    this.fontSize = 32.0,
    this.fontWeight = FontWeightOption.normal,
    this.horizontalPadding = 48.0,
    this.lineHeight = 1.6,
    this.letterSpacing = 0.0,
    this.textColor = TextColorOption.pureWhite,
    this.mirrorMode = false,
    this.optimizationPreset = OptimizationPreset.standard,
    this.scrollSpeed = 1.0,
    this.manualScrollStep = ManualScrollStep.medium,
    this.pageJumpSize = PageJumpSize.fifteen,
    this.ghostReductionOverlay = false,
    this.showLastKeyReceived = false,
    this.showRemoteDebugInfo = false,
  });

  // ── Range constants ────────────────────────────────────────────────
  static const double minFontSize = 16.0;
  static const double maxFontSize = 96.0;
  static const double minScrollSpeed = 0.1;
  static const double maxScrollSpeed = 10.0;
  static const double minHorizontalPadding = 0.0;
  static const double maxHorizontalPadding = 100.0;
  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 3.0;
  static const double minLetterSpacing = 0.0;
  static const double maxLetterSpacing = 5.0;

  // ── Resolved text style ────────────────────────────────────────────
  /// Computes the final [TextStyle] by composing the base reader
  /// appearance with any overrides from the active [optimizationPreset].
  TextStyle resolvedTextStyle() {
    // Start from the user's explicit settings.
    FontWeight resolvedWeight = fontWeight.weight;
    Color resolvedColor = textColor.color;
    double resolvedLineHeight = lineHeight;
    double resolvedLetterSpacing = letterSpacing;

    // Apply preset overrides.
    switch (optimizationPreset) {
      case OptimizationPreset.standard:
        // No modifications.
        break;
      case OptimizationPreset.bold:
        // Increase weight by one step (capped at w800).
        resolvedWeight = _bumpWeight(resolvedWeight);
        break;
      case OptimizationPreset.highContrast:
        resolvedColor = const Color(0xFFFFFFFF);
        break;
      case OptimizationPreset.ghostReduction:
        resolvedWeight = FontWeight.w600;
        resolvedColor = const Color(0xFFF0F0F0); // soft white
        resolvedLineHeight = (resolvedLineHeight + 0.2).clamp(
          minLineHeight,
          maxLineHeight,
        );
        resolvedLetterSpacing = (resolvedLetterSpacing + 0.5).clamp(
          minLetterSpacing,
          maxLetterSpacing,
        );
        break;
    }

    return TextStyle(
      color: resolvedColor,
      fontSize: fontSize,
      fontWeight: resolvedWeight,
      height: resolvedLineHeight,
      letterSpacing: resolvedLetterSpacing,
    );
  }

  /// Bumps a [FontWeight] up by one standard step.
  static FontWeight _bumpWeight(FontWeight w) {
    const steps = [
      FontWeight.w100,
      FontWeight.w200,
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
      FontWeight.w800,
      FontWeight.w900,
    ];
    final idx = steps.indexOf(w);
    if (idx < 0 || idx >= steps.length - 1) return steps.last;
    return steps[idx + 1];
  }

  // ── copyWith ───────────────────────────────────────────────────────
  AppSettings copyWith({
    double? fontSize,
    FontWeightOption? fontWeight,
    double? horizontalPadding,
    double? lineHeight,
    double? letterSpacing,
    TextColorOption? textColor,
    bool? mirrorMode,
    OptimizationPreset? optimizationPreset,
    double? scrollSpeed,
    ManualScrollStep? manualScrollStep,
    PageJumpSize? pageJumpSize,
    bool? ghostReductionOverlay,
    bool? showLastKeyReceived,
    bool? showRemoteDebugInfo,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      textColor: textColor ?? this.textColor,
      mirrorMode: mirrorMode ?? this.mirrorMode,
      optimizationPreset: optimizationPreset ?? this.optimizationPreset,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      manualScrollStep: manualScrollStep ?? this.manualScrollStep,
      pageJumpSize: pageJumpSize ?? this.pageJumpSize,
      ghostReductionOverlay:
          ghostReductionOverlay ?? this.ghostReductionOverlay,
      showLastKeyReceived: showLastKeyReceived ?? this.showLastKeyReceived,
      showRemoteDebugInfo: showRemoteDebugInfo ?? this.showRemoteDebugInfo,
    );
  }
}
