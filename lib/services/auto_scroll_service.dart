import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollService {
  Timer? _timer;
  Timer? _resumeTimer;
  double _cachedSpeed = 1.0;
  bool _isPausedForManualAdjustment = false;

  bool get isRunning => _timer != null && _timer!.isActive;

  bool get isResumeTimerActive => _resumeTimer != null && _resumeTimer!.isActive;

  /// Set by the UI when the user is actively dragging the scroll view.
  /// While true, auto-scroll ticks are skipped (no timer conflicts).
  bool isUserDragging = false;

  /// Debug: count of ticks skipped due to pause state
  int _skippedTicks = 0;

  void start(
    ScrollController controller,
    double initialSpeed,
    void Function(double) onPositionUpdate,
    double Function() onReadSpeed,
  ) {
    stop();
    _cachedSpeed = initialSpeed;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isPausedForManualAdjustment || isUserDragging || !controller.hasClients) {
        _skippedTicks++;
        return;
      }
      if (_skippedTicks > 0) {
        _skippedTicks = 0;
      }
      final maxExtent = controller.position.maxScrollExtent;
      if (maxExtent <= 0) return;
      final currentOffset = controller.offset;
      if (currentOffset >= maxExtent && maxExtent > 0) {
        onPositionUpdate(1.0);
        stop();
        return;
      }
      _cachedSpeed = onReadSpeed();
      final pixelDelta = _cachedSpeed * 0.05 / 100.0 * maxExtent;
      final newOffset = (currentOffset + pixelDelta).clamp(0.0, maxExtent);
      controller.jumpTo(newOffset);
      onPositionUpdate(newOffset / maxExtent);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _isPausedForManualAdjustment = false;
    isUserDragging = false;
    _skippedTicks = 0;
  }

  void pauseForManualAdjustment(Duration delay, VoidCallback onResume) {
    _isPausedForManualAdjustment = true;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(delay, () {
      _isPausedForManualAdjustment = false;
      _resumeTimer = null;
      onResume();
    });
  }

  void cancelResumeTimer() {
    _resumeTimer?.cancel();
    _resumeTimer = null;
  }
}
