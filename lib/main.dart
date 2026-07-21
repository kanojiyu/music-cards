import 'package:flutter/material.dart';

import 'app_dependencies.dart';
import 'data/database.dart';
import 'ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deps = AppDependencies.persistent(database: AppDatabase());

  runApp(MusicCardsApp(deps: deps));
}

class MusicCardsApp extends StatelessWidget {
  const MusicCardsApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F6BD6)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F6BD6),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(deps: deps),
    );
  }
}
