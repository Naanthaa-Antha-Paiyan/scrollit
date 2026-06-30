import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/scripts_provider.dart';
import '../widgets/script_tile.dart';
import 'script_editor_screen.dart';

class ScriptListScreen extends ConsumerWidget {
  const ScriptListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripts = ref.watch(scriptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScriptEditorScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: scripts.isEmpty
          ? EmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'No scripts yet',
              subtitle: 'Tap + to create your first script',
              action: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScriptEditorScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Script'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: scripts.length,
              itemBuilder: (context, index) {
                final script = scripts[index];
                return ScriptTile(
                  script: script,
                  onTap: () => _openScript(context, ref, script.id),
                  onEdit: () => _openEditor(context, script),
                  onRename: () => _showRenameDialog(context, ref, script),
                  onDelete: () => _confirmDelete(context, ref, script),
                );
              },
            ),
    );
  }

  void _openScript(BuildContext context, WidgetRef ref, String id) {
    Navigator.of(context).pushNamed('/reader', arguments: id);
  }

  void _openEditor(BuildContext context, script) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScriptEditorScreen(script: script),
      ),
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref, script) async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => _RenameDialog(initialText: script.title),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      await ref.read(scriptsProvider.notifier).rename(script.id, newTitle);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, script) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Script'),
        content: Text('Are you sure you want to delete "${script.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(scriptsProvider.notifier).delete(script.id);
    }
  }
}

class _RenameDialog extends StatefulWidget {
  final String initialText;
  const _RenameDialog({required this.initialText});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Script'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Script title',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
