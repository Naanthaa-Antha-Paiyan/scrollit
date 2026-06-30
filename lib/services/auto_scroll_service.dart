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
    // ignore: avoid_print
    print('[Scrollit][AutoScroll] START — speed=$initialSpeed');
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_isPausedForManualAdjustment || isUserDragging || !controller.hasClients) {
        _skippedTicks++;
        if (_skippedTicks == 1 || _skippedTicks % 60 == 0) {
          // ignore: avoid_print
          print('[Scrollit][AutoScroll] TICK SKIPPED (#$_skippedTicks) — paused=$_isPausedForManualAdjustment dragging=$isUserDragging hasClients=${controller.hasClients}');
        }
        return;
      }
      if (_skippedTicks > 0) {
        // ignore: avoid_print
        print('[Scrollit][AutoScroll] TICK RESUMED after $_skippedTicks skipped ticks');
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
    // ignore: avoid_print
    print('[Scrollit][AutoScroll] STOP — wasRunning=$isRunning paused=$_isPausedForManualAdjustment dragging=$isUserDragging resumeTimerActive=$isResumeTimerActive');
    _timer?.cancel();
    _timer = null;
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _isPausedForManualAdjustment = false;
    isUserDragging = false;
    _skippedTicks = 0;
  }

  void pauseForManualAdjustment(Duration delay, VoidCallback onResume) {
    final wasPaused = _isPausedForManualAdjustment;
    final hadResumeTimer = isResumeTimerActive;
    _isPausedForManualAdjustment = true;
    _resumeTimer?.cancel();
    // ignore: avoid_print
    print('[Scrollit][AutoScroll] PAUSE_MANUAL — wasPaused=$wasPaused hadResumeTimer=$hadResumeTimer delay=${delay.inMilliseconds}ms isRunning=$isRunning');
    _resumeTimer = Timer(delay, () {
      _isPausedForManualAdjustment = false;
      _resumeTimer = null;
      // ignore: avoid_print
      print('[Scrollit][AutoScroll] RESUME_MANUAL — timer fired, isRunning=$isRunning dragging=$isUserDragging');
      onResume();
    });
  }

  void cancelResumeTimer() {
    // ignore: avoid_print
    print('[Scrollit][AutoScroll] CANCEL_RESUME_TIMER — wasActive=$isResumeTimerActive');
    _resumeTimer?.cancel();
    _resumeTimer = null;
  }
}
