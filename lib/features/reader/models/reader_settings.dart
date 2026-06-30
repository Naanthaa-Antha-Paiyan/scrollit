class ReaderSettings {
  final double fontSize;
  final double scrollSpeed;
  final double horizontalPadding;
  final bool mirrorMode;

  const ReaderSettings({
    this.fontSize = 32.0,
    this.scrollSpeed = 1.0,
    this.horizontalPadding = 48.0,
    this.mirrorMode = false,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? scrollSpeed,
    double? horizontalPadding,
    bool? mirrorMode,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      mirrorMode: mirrorMode ?? this.mirrorMode,
    );
  }

  static const double minFontSize = 16.0;
  static const double maxFontSize = 72.0;
  static const double minScrollSpeed = 0.1;
  static const double maxScrollSpeed = 10.0;
  static const double minHorizontalPadding = 16.0;
  static const double maxHorizontalPadding = 200.0;
}
