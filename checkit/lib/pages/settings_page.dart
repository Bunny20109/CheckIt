// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> clearData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('shopping_items');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data belanja berhasil dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Mode Gelap'),
          subtitle: Text(themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif'),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
          secondary: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder:
                (child, animation) =>
                    RotationTransition(turns: animation, child: child),
            child:
                themeProvider.isDarkMode
                    ? const Icon(
                      Icons.dark_mode,
                      key: ValueKey('moon'),
                      color: Colors.amber,
                    )
                    : const Icon(
                      Icons.light_mode,
                      key: ValueKey('sun'),
                      color: Colors.orange,
                    ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text('Hapus Semua Data'),
          onTap: () => clearData(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Tentang Aplikasi'),
          subtitle: const Text('Daftar Belanja v1.0\nDibuat oleh Kamu 👩‍💻'),
        ),
      ],
    );
  }
}
