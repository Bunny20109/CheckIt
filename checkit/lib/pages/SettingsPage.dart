import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDark = themeNotifier.isDark;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ListTile(
          title: Text('Mode Gelap'),
          trailing: Switch(
            value: isDark,
            onChanged: (val) => themeNotifier.toggleTheme(val),
          ),
        ),
        ListTile(
          title: Text('Tentang Aplikasi'),
          subtitle: Text('CheckIt v1.0.0'),
        ),
      ],
    );
  }
}
