import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/scripts/screens/script_editor_screen.dart';
import '../features/scripts/screens/script_list_screen.dart';
import '../features/reader/screens/reader_screen.dart';
import 'theme.dart';

class ScrollitApp extends ConsumerWidget {
  const ScrollitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Scrollit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const ScriptListScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/reader') {
          final scriptId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ReaderScreen(scriptId: scriptId),
          );
        }
        if (settings.name == '/editor') {
          return MaterialPageRoute(
            builder: (_) => const ScriptEditorScreen(),
          );
        }
        return null;
      },
    );
  }
}
