import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bootstrap.dart';
import 'features/vocabulary/presentation/pages/main_screen.dart';

Future<void> main() async {
  final container = await bootstrap();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.dmSansTextTheme();

    return MaterialApp(
      title: 'Gocab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF111C2E),
          secondary: const Color(0xFF0F766E),
          surface: const Color(0xFFF4F8FD),
        ),
        useMaterial3: true,
        textTheme: textTheme.apply(
          bodyColor: const Color(0xFF15243A),
          displayColor: const Color(0xFF15243A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7FC),
      ),
      home: const MainScreen(),
    );
  }
}
