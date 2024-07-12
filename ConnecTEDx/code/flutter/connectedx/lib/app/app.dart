import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectedx/pages/home/home_page.dart';
import 'package:connectedx/pages/settings/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConnecTEDx',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ref.watch(accentColorProvider),
          brightness: ref.watch(brightnessProvider),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}
