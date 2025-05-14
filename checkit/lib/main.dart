// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedTheme(
      data:
          themeProvider.isDarkMode
              ? ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: Colors.deepPurple),
              )
              : ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.deepPurple,
                ),
              ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Daftar Belanja',
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.deepPurple),
        ),
        home: const AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: HomePage(),
        ),
      ),
    );
  }
}
