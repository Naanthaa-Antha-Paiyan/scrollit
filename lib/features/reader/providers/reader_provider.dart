import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scripts/providers/scripts_provider.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/app_settings_provider.dart';

final readerProvider =
    StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  final scripts = ref.read(scriptsProvider.notifier);
  return ReaderNotifier(scripts, ref);
});

class ReaderState {
  final String? scriptId;
  final bool isAutoScrolling;
  final bool isFullscreen;
  final bool showControls;
  final double position;

  const ReaderState({
    this.scriptId,
    this.isAutoScrolling = false,
    this.isFullscreen = false,
    this.showControls = false,
    this.position = 0.0,
  });

  ReaderState copyWith({
    String? scriptId,
    bool? isAutoScrolling,
    bool? isFullscreen,
    bool? showControls,
    double? position,
  }) {
    return ReaderState(
      scriptId: scriptId ?? this.scriptId,
      isAutoScrolling: isAutoScrolling ?? this.isAutoScrolling,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      showControls: showControls ?? this.showControls,
      position: position ?? this.position,
    );
  }
}

class ReaderNotifier extends StateNotifier<ReaderState> {
  final ScriptsNotifier _scripts;
  final Ref _ref;
  Timer? _controlsTimer;
  Timer? _positionSaveTimer;

  ReaderNotifier(this._scripts, this._ref)
      : super(const ReaderState());

  void openScript(String id) {
    _scripts.setLastOpened(id);
    final position = _scripts.loadPosition(id);
    state = state.copyWith(
      scriptId: id,
      position: position,
      isAutoScrolling: false,
      isFullscreen: false,
      showControls: true,
    );
    _startPositionSaveTimer();
  }

  void closeScript() {
    stopAutoScroll();
    _positionSaveTimer?.cancel();
    state = const ReaderState();
  }

  void cleanup() {
    _controlsTimer?.cancel();
    _positionSaveTimer?.cancel();
  }

  void setPosition(double position) {
    state = state.copyWith(position: position.clamp(0.0, 1.0));
  }

  Future<void> savePosition() async {
    if (state.scriptId != null) {
      await _scripts.savePosition(state.scriptId!, state.position);
    }
  }

  void toggleAutoScroll() {
    if (state.isAutoScrolling) {
      stopAutoScroll();
    } else {
      startAutoScroll();
    }
  }

  void startAutoScroll() {
    if (state.isAutoScrolling) return;
    state = state.copyWith(isAutoScrolling: true);
  }

  void stopAutoScroll() {
    if (!state.isAutoScrolling) return;
    state = state.copyWith(isAutoScrolling: false);
  }

  void adjustSpeed(double delta) {
    final settingsNotifier = _ref.read(appSettingsProvider.notifier);
    final current = _ref.read(appSettingsProvider).scrollSpeed;
    settingsNotifier.setScrollSpeed((current + delta).clamp(
      AppSettings.minScrollSpeed,
      AppSettings.maxScrollSpeed,
    ));
  }

  void scrollUp() {
    final step = _ref.read(appSettingsProvider).manualScrollStep.delta;
    state = state.copyWith(
        position: (state.position - step).clamp(0.0, 1.0));
  }

  void scrollDown() {
    final step = _ref.read(appSettingsProvider).manualScrollStep.delta;
    state = state.copyWith(
        position: (state.position + step).clamp(0.0, 1.0));
  }

  void pageUp() {
    final jump = _ref.read(appSettingsProvider).pageJumpSize.fraction;
    state = state.copyWith(
        position: (state.position - jump).clamp(0.0, 1.0));
  }

  void pageDown() {
    final jump = _ref.read(appSettingsProvider).pageJumpSize.fraction;
    state = state.copyWith(
        position: (state.position + jump).clamp(0.0, 1.0));
  }

  void toggleFullscreen() {
    final willBeFullscreen = !state.isFullscreen;
    state = state.copyWith(
      isFullscreen: willBeFullscreen,
      showControls: !willBeFullscreen,
    );
    if (!willBeFullscreen) {
      _controlsTimer?.cancel();
    }
  }

  void exitFullscreen() {
    if (state.isFullscreen) {
      state = state.copyWith(isFullscreen: false, showControls: true);
    }
  }

  /// Toggles controls visibility. In fullscreen mode, showing controls
  /// starts an auto-hide timer. In non-fullscreen mode, controls stay
  /// visible until explicitly toggled off.
  void toggleControls() {
    if (state.showControls) {
      state = state.copyWith(showControls: false);
      _controlsTimer?.cancel();
    } else {
      state = state.copyWith(showControls: true);
      if (state.isFullscreen) {
        _startControlsAutoHideTimer();
      }
    }
  }

  /// Shows controls and, if in fullscreen, starts an auto-hide timer.
  /// Used by keyboard events and fullscreen toggle.
  void showControlsTemporarily() {
    state = state.copyWith(showControls: true);
    if (state.isFullscreen) {
      _startControlsAutoHideTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _startControlsAutoHideTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        state = state.copyWith(showControls: false);
      }
    });
  }

  void _startPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      savePosition();
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _positionSaveTimer?.cancel();
    super.dispose();
  }
}
