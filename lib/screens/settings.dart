import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  Future<void> _confirmAndClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all items?'),
        content: const Text(
            'This will permanently delete all items from the remote database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final url = Uri.https(
      'proj-315a8-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to clear remote items.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All items cleared.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while clearing items.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          SwitchListTile(
            title: const Text('Dark theme'),
            secondary: const Icon(Icons.brightness_6),
            value: settings.isDark,
            onChanged: (val) => settings.setDark(val),
          ),

          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Text('Accent color', style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          // Theme color presets
          _ThemeColorRadio(
            groupValue: settings.seedValue,
            onChanged: (v) => settings.setSeed(v),
          ),

          // Placeholder for a future setting
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Another setting'),
            subtitle: const Text('Space reserved for a future toggle'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: implement action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Not implemented yet')),
                );
              },
              child: const Text('Action'),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear saved items (remote)'),
            subtitle:
                const Text('Deletes all items from Firebase Realtime DB'),
            trailing: TextButton(
              onPressed: () => _confirmAndClear(context),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Shopping List',
              applicationVersion: '1.0.0',
              children: const [Text('A simple shopping list example app.')],
            ),
          ),
        ],
      ),
    );
  }
}
class _ThemeColorRadio extends StatelessWidget {
  final int groupValue;
  final ValueChanged<int> onChanged;

  const _ThemeColorRadio({required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <Map<String, int>>[
      {'Cyan': 0xFF93E5FA},
      {'Teal': 0xFF4DB6AC},
      {'Amber': 0xFFFFC107},
    ];

    return Column(
      children: options.map((opt) {
        final name = opt.keys.first;
        final value = opt.values.first;
        return RadioListTile<int>(
          value: value,
          groupValue: groupValue,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          title: Text(name),
          secondary: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(value),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12),
            ),
          ),
        );
      }).toList(),
    );
  }
}



