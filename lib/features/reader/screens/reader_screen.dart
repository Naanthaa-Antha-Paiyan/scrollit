import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/analytics_service.dart';
import '../../../utils/web_fullscreen.dart';
import '../../scripts/providers/scripts_provider.dart';
import '../../settings/providers/app_settings_provider.dart';
import '../../../services/auto_scroll_service.dart';
import '../../../services/presenter_remote_service.dart';
import '../providers/reader_provider.dart';
import '../widgets/reader_controls.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String scriptId;

  const ReaderScreen({super.key, required this.scriptId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final AutoScrollService _autoScrollService = AutoScrollService();
  final PresenterRemoteService _remoteService = PresenterRemoteService();
  final AnalyticsService _analytics = AnalyticsService.instance;
  ReaderNotifier? _readerNotifier;
  bool _isLoaded = false;
  String? _scriptContent;
  String? _scriptTitle;
  Timer? _speedOverlayTimer;
  double? _lastSpeed;
  bool _showSpeedOverlay = false;
  String? _lastKeyLabel;
  static const _manualScrollResumeDelay = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    // Lock to landscape while reader is active.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _scrollController.addListener(_onScrollChanged);
    ref.listenManual(readerProvider, _onReaderStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _readerNotifier = ref.read(readerProvider.notifier);
      _readerNotifier!.openScript(widget.scriptId);
      _loadContent();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _analytics.logReaderClosed(scriptId: widget.scriptId);
    _autoScrollService.stop();
    _speedOverlayTimer?.cancel();
    _readerNotifier?.savePosition();
    _readerNotifier?.cleanup();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _focusNode.dispose();
    // Restore all orientations when leaving the reader.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onReaderStateChanged(ReaderState? prev, ReaderState next) {
    if (prev == null) return;
    if (prev.isFullscreen != next.isFullscreen) {
      _onFullscreenChanged(next.isFullscreen);
    }
    if (prev.isAutoScrolling != next.isAutoScrolling) {
      _onAutoScrollChanged(next.isAutoScrolling);
    }
  }

  void _onFullscreenChanged(bool isFullscreen) {
    SystemChrome.setEnabledSystemUIMode(
      isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    // On web, also toggle the browser's native fullscreen (hides tab bar,
    // address bar, etc.). This is a no-op on non-web platforms.
    if (isFullscreen) {
      enterBrowserFullscreen();
    } else {
      exitBrowserFullscreen();
    }
    if (!isFullscreen) _reclaimFocus();
  }

  void _onAutoScrollChanged(bool isAutoScrolling) {
    if (isAutoScrolling) {
      _analytics.logAutoScrollStarted();
      _autoScrollService.start(
        _scrollController,
        ref.read(appSettingsProvider).scrollSpeed,
        _onAutoScrollTick,
        () => ref.read(appSettingsProvider).scrollSpeed,
      );
    } else {
      _analytics.logAutoScrollStopped();
      _autoScrollService.stop();
    }
  }

  void _loadContent() {
    final scripts = ref.read(scriptsProvider);
    final script = scripts.isEmpty
        ? null
        : scripts.firstWhere((s) => s.id == widget.scriptId,
            orElse: () => scripts.first);
    if (script != null) {
      _scriptTitle = script.title;
      _scriptContent = ref.read(scriptsProvider.notifier).loadContent(script.id);
      _isLoaded = true;
      _analytics.logReaderOpened(scriptId: script.id);
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _restorePosition();
        });
      }
    }
  }


  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent > 0) {
      final pos = _scrollController.offset / maxExtent;
      final clamped = pos.clamp(0.0, 1.0);
      ref.read(readerProvider.notifier).setPosition(clamped);
    }
  }

  void _jumpTo(double offset) {
    if (!_scrollController.hasClients) {
      return;
    }
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) {
      return;
    }
    try {
      final clamped = offset.clamp(0.0, maxExtent);
      _scrollController.jumpTo(clamped);
    } catch (e) {
      // Do nothing
    }
  }

  void _syncScrollToPosition(double position) {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent > 0) {
      _jumpTo(position * maxExtent);
    }
  }

  void _doManualScroll(double direction, String label) {
    _analytics.logManualScrollUsed();
    _autoScrollService.pauseForManualAdjustment(
      _manualScrollResumeDelay,
      _onManualAdjustmentEnd,
    );

    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    // Scroll by 50% of the visible viewport height.
    final viewportPixels =
        _scrollController.position.viewportDimension * 0.5;
    final pixelDelta = direction > 0 ? viewportPixels : -viewportPixels;
    final targetOffset =
        (_scrollController.offset + pixelDelta).clamp(0.0, maxExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _restorePosition() {
    if (!_isLoaded) return;
    final readerState = ref.read(readerProvider);
    if (readerState.position <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryRestore(readerState.position, retries: 5);
    });
  }

  void _tryRestore(double position, {int retries = 5}) {
    if (!mounted) return;
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent <= 0) {
      if (retries > 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _tryRestore(position, retries: retries - 1);
        });
      }
      return;
    }
    _syncScrollToPosition(position);
  }

  void _onAutoScrollTick(double position) {
    final notifier = ref.read(readerProvider.notifier);
    if (position >= 1.0) {
      notifier.stopAutoScroll();
      return;
    }
    notifier.setPosition(position);
  }

  void _onManualAdjustmentEnd() {
    // Auto-scroll resumes naturally via AutoScrollService.
    // No state update needed since isAutoScrolling is still true.
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    _remoteService.onKeyEvent(event);

    // Track last key for debug overlay.
    if (event is KeyDownEvent) {
      _updateLastKey(event.logicalKey);

      if (_remoteService.detectFullscreenSequence()) {
        ref.read(readerProvider.notifier).toggleFullscreen();
        return KeyEventResult.handled;
      }
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final notifier = ref.read(readerProvider.notifier);
    final settings = ref.read(appSettingsProvider);

    if (event.logicalKey == LogicalKeyboardKey.keyB) {
      notifier.toggleAutoScroll();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (ref.read(readerProvider).isFullscreen) {
        notifier.exitFullscreen();
        _reclaimFocus();
      }
      return KeyEventResult.handled;
    }

    final manualDelta = settings.manualScrollStep.delta;
    final pageDelta = settings.pageJumpSize.fraction;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _doManualScroll(-manualDelta, 'Arrow Up');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _doManualScroll(manualDelta, 'Arrow Down');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        _doManualScroll(-pageDelta, 'Page Up');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        _doManualScroll(pageDelta, 'Page Down');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        notifier.adjustSpeed(-ReaderNotifier.defaultSpeedDelta);
        _showSpeedOverlayNow(ref.read(appSettingsProvider).scrollSpeed);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        notifier.adjustSpeed(ReaderNotifier.defaultSpeedDelta);
        _showSpeedOverlayNow(ref.read(appSettingsProvider).scrollSpeed);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _updateLastKey(LogicalKeyboardKey key) {
    setState(() {
      _lastKeyLabel = key.keyLabel.isNotEmpty ? key.keyLabel : key.debugName ?? 'Unknown';
    });
  }

  void _showSpeedOverlayNow(double speed) {
    _lastSpeed = speed;
    _showSpeedOverlay = true;
    _speedOverlayTimer?.cancel();
    _speedOverlayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showSpeedOverlay = false);
      }
    });
    if (mounted) setState(() {});
  }

  void _reclaimFocus() {
    _focusNode.requestFocus();
  }

  void _handleBack() {
    final notifier = ref.read(readerProvider.notifier);
    if (ref.read(readerProvider).isFullscreen) {
      notifier.exitFullscreen();
      _reclaimFocus();
      return;
    }
    notifier.savePosition();
    notifier.closeScript();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider);
    final settings = ref.watch(appSettingsProvider);
    final resolvedStyle = settings.resolvedTextStyle();

    final body = GestureDetector(
      onTap: () {
        ref.read(readerProvider.notifier).toggleControls();
        _reclaimFocus();
      },
      child: Listener(
        onPointerDown: (_) {
          _autoScrollService.isUserDragging = true;
        },
        onPointerUp: (_) {
          _autoScrollService.isUserDragging = false;
        },
        onPointerCancel: (_) {
          _autoScrollService.isUserDragging = false;
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: settings.horizontalPadding),
                    child: settings.mirrorMode
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4(
                              -1, 0, 0, 0,
                              0, 1, 0, 0,
                              0, 0, 1, 0,
                              0, 0, 0, 1,
                            ),
                            child: Text(
                              _scriptContent ?? '',
                              style: resolvedStyle,
                            ),
                          )
                        : Text(
                            _scriptContent ?? '',
                            style: resolvedStyle,
                          ),
                  ),
                ),
              ),
              if (readerState.showControls)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    child: ReaderControls(),
                  ),
                ),
              if (readerState.isAutoScrolling && !readerState.showControls)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      settings.scrollSpeed.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ),
                ),
              if (_showSpeedOverlay && _lastSpeed != null)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Speed: ${_lastSpeed!.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              // ── Remote debug overlays ──────────────────────────────
              if (settings.showLastKeyReceived && _lastKeyLabel != null && !settings.showRemoteDebugInfo)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildDebugChip('Last Key: $_lastKeyLabel'),
                ),
              if (settings.showRemoteDebugInfo)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDebugChip('Last Key: ${_lastKeyLabel ?? '—'}'),
                      const SizedBox(height: 4),
                      _buildDebugChip(
                        'Auto-scroll: ${readerState.isAutoScrolling ? 'ON' : 'OFF'}',
                      ),
                      const SizedBox(height: 4),
                      _buildDebugChip(
                        'Speed: ${settings.scrollSpeed.toStringAsFixed(1)}x',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: readerState.isFullscreen
              ? null
              : AppBar(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  title: Text(
                    _scriptTitle ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _handleBack,
                  ),
                ),
          body: body,
        ),
      ),
    );
  }

  Widget _buildDebugChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
