import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/persistence_service.dart';
import '../../scripts/providers/scripts_provider.dart';
import '../models/reader_settings.dart';

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
  final persistence = ref.read(persistenceServiceProvider);
  return ReaderSettingsNotifier(persistence);
});

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  final PersistenceService _persistence;

  ReaderSettingsNotifier(this._persistence)
      : super(const ReaderSettings()) {
    _load();
  }

  void _load() {
    state = _persistence.loadReaderSettings();
  }

  Future<void> _persist() async {
    await _persistence.saveReaderSettings(state);
  }

  Future<void> setFontSize(double value) async {
    state = state.copyWith(fontSize: value.clamp(
      ReaderSettings.minFontSize,
      ReaderSettings.maxFontSize,
    ));
    await _persist();
  }

  Future<void> setScrollSpeed(double value) async {
    state = state.copyWith(scrollSpeed: value.clamp(
      ReaderSettings.minScrollSpeed,
      ReaderSettings.maxScrollSpeed,
    ));
    await _persist();
  }

  Future<void> setHorizontalPadding(double value) async {
    state = state.copyWith(horizontalPadding: value.clamp(
      ReaderSettings.minHorizontalPadding,
      ReaderSettings.maxHorizontalPadding,
    ));
    await _persist();
  }

  Future<void> toggleMirrorMode() async {
    state = state.copyWith(mirrorMode: !state.mirrorMode);
    await _persist();
  }
}
