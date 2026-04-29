import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CountryExplorerApp());
}

class CountryExplorerApp extends StatefulWidget {
  const CountryExplorerApp({super.key});

  static _CountryExplorerAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_CountryExplorerAppState>();

  @override
  State<CountryExplorerApp> createState() => _CountryExplorerAppState();
}

class _CountryExplorerAppState extends State<CountryExplorerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}
