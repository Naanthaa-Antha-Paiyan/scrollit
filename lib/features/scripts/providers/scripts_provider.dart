import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../services/persistence_service.dart';
import '../models/script.dart';

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final scriptsProvider =
    StateNotifierProvider<ScriptsNotifier, List<Script>>((ref) {
  final persistence = ref.read(persistenceServiceProvider);
  return ScriptsNotifier(persistence);
});

class ScriptsNotifier extends StateNotifier<List<Script>> {
  final PersistenceService _persistence;
  static const _uuid = Uuid();

  ScriptsNotifier(this._persistence) : super([]) {
    _load();
  }

  void _load() {
    state = _persistence.loadScripts();
  }

  Future<void> _persist() async {
    await _persistence.saveScripts(state);
  }

  Future<Script> create(String title, String content) async {
    final now = DateTime.now();
    final script = Script(
      id: _uuid.v4(),
      title: title,
      content: content,
      wordCount: Script.countWords(content),
      createdAt: now,
      updatedAt: now,
    );
    await _persistence.saveScriptContent(script.id, content);
    state = [...state, script];
    await _persist();
    return script;
  }

  Future<void> update(Script script) async {
    final updated = script.copyWith(
      wordCount: Script.countWords(script.content),
      updatedAt: DateTime.now(),
    );
    state = [
      for (final s in state)
        if (s.id == updated.id) updated else s
    ];
    await _persistence.saveScriptContent(updated.id, updated.content);
    await _persist();
  }

  Future<void> rename(String id, String newTitle) async {
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(title: newTitle, updatedAt: DateTime.now()) else s
    ];
    await _persist();
  }

  Future<void> delete(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _persistence.deleteScriptContent(id);
    await _persist();
  }

  Script? getById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  String loadContent(String id) {
    return _persistence.loadScriptContent(id);
  }

  Future<void> savePosition(String id, double position) async {
    await _persistence.saveScriptPosition(id, position);
  }

  double loadPosition(String id) {
    return _persistence.loadScriptPosition(id);
  }

  void setLastOpened(String id) {
    _persistence.setLastOpenedScript(id);
  }

  String? getLastOpened() {
    return _persistence.getLastOpenedScript();
  }
}
