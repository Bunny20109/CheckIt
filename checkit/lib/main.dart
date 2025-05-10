import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/ShoppingListPage.dart';
import 'pages/AddItemPage.dart';
import 'pages/HistoryPage.dart';
import 'pages/SettingsPage.dart';
import 'theme/theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const CheckItApp(),
    ),
  );
}

class CheckItApp extends StatelessWidget {
  const CheckItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'CheckIt',
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.currentTheme,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF6A1B9A), // Ungu cerah
          secondary: Color(0xFFFFC107), // Kuning cerah
          background: Color(0xFFF3E5F5), // Ungu muda
        ),
        scaffoldBackgroundColor: Color(0xFFFDF6FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF6A1B9A),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFB388FF), // Ungu terang di dark mode
          secondary: Color(0xFFFFD54F), // Kuning terang
          surface: Color(0xFF212121),
          background: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFB388FF),
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),
      home: MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ShoppingListPage(),
    AddItemPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  final List<String> _titles = [
    "Daftar Belanja",
    "Tambah Item",
    "Riwayat",
    "Pengaturan",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Belanja'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
