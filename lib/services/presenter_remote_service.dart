import 'package:flutter/services.dart';

class PresenterRemoteService {
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  DateTime _lastSequenceTime = DateTime(2000);
  bool _sequenceInProgress = false;
  bool _debugLogging = true;

  static const _sequenceTimeout = Duration(milliseconds: 500);

  bool get isDebugLogging => _debugLogging;

  set debugLogging(bool v) => _debugLogging = v;

  void onKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    } else if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    }

    if (_sequenceInProgress && !_allSequenceKeysPressed()) {
      _sequenceInProgress = false;
    }
  }

  bool isKey(LogicalKeyboardKey key) => _pressedKeys.contains(key);

  bool consumeKey(LogicalKeyboardKey key) => _pressedKeys.remove(key);

  void clearKeys() => _pressedKeys.clear();

  bool detectFullscreenSequence() {
    final now = DateTime.now();
    if (_sequenceInProgress || now.difference(_lastSequenceTime) < _sequenceTimeout) {
      return false;
    }
    if (_allSequenceKeysPressed()) {
      _sequenceInProgress = true;
      _lastSequenceTime = now;
      if (_debugLogging) {
        // ignore: avoid_print
        print('[Scrollit] Fullscreen sequence detected');
      }
      return true;
    }
    return false;
  }

  bool _allSequenceKeysPressed() {
    final hasP = _pressedKeys.contains(LogicalKeyboardKey.keyP);
    final hasMeta = _pressedKeys.any(
        (k) => k == LogicalKeyboardKey.metaLeft || k == LogicalKeyboardKey.metaRight);
    final hasAlt = _pressedKeys.any(
        (k) => k == LogicalKeyboardKey.altLeft || k == LogicalKeyboardKey.altRight);
    final hasF5 = _pressedKeys.contains(LogicalKeyboardKey.f5);
    final hasShift = _pressedKeys.any(
        (k) => k == LogicalKeyboardKey.shiftLeft || k == LogicalKeyboardKey.shiftRight);
    return hasP && hasMeta && hasAlt && hasF5 && hasShift;
  }
}
