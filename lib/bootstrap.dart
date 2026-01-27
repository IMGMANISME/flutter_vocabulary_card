import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // For WidgetsFlutterBinding
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/vocabulary/presentation/providers/vocabulary_providers.dart';
import 'firebase_options.dart';

Future<ProviderContainer> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle error or ignore if already initialized
    debugPrint('Firebase init error: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  return container;
}
