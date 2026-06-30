import 'package:flutter/material.dart';
import 'package:scrollit/features/scripts/screens/script_editor_screen.dart';
import '../../features/scripts/screens/script_list_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

/// Bottom navigation shell containing the Scripts and Settings tabs.
///
/// Uses [IndexedStack] to preserve tab state when switching.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _tabs = [
    ScriptListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: Visibility(
        visible: _currentIndex == 0,
        child: FloatingActionButton(
          onPressed: () {
            final route = MaterialPageRoute(builder: (_) => const ScriptEditorScreen());
            Navigator.of(context).push(route);
          },
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).cardTheme.color,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Scripts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
