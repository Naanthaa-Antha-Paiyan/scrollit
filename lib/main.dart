import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'features/scripts/providers/scripts_provider.dart';
import 'services/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final persistenceService = PersistenceService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(persistenceService),
      ],
      child: const ScrollitApp(),
    ),
  );
}
