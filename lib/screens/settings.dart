import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shopping_list/services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  // Clear-all feature removed per user request.

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
            child: Text('Accent color',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          // Theme color presets
          _ThemeColorRadio(
            groupValue: settings.seedValue,
            onChanged: (v) => settings.setSeed(v),
          ),

          // No color strength slider — accent color uses full strength.

          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Shopping List',
              applicationVersion: '1.0.0',
              children: const [Text('A simple app for shopping lists.')],
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
      {'Cyan': 0xFF00BCD4},
      {'Blue': 0xFF2196F3},
      {'Purple': 0xFF9C27B0},
      {'Pink': 0xFFE91E63},
      {'Red': 0xFFF44336},
      {'Orange': 0xFFFF9800},
      {'Green': 0xFF4CAF50},
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
