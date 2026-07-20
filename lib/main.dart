import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'features/scripts/providers/scripts_provider.dart';
import 'services/analytics_service.dart';
import 'services/persistence_service.dart';
import 'services/version_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ── Firebase initialization (failures must never block app startup) ──
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AnalyticsService.instance.init();
  } catch (e) {
    debugPrint('Firebase initialization failed — $e');
  }

  // ── Set version properties on analytics ──
  try {
    final versionService = await VersionService.init();
    await AnalyticsService.instance.setVersionProperties(versionService);
  } catch (e) {
    debugPrint('Version service initialization failed — $e');
  }

  // ── Log app opened event ──
  AnalyticsService.instance.logAppOpened();

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
