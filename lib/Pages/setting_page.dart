import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold( // Added Scaffold for proper layout
      appBar: !isMobile ? AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
      ) : null,
      body: SingleChildScrollView( // Wrapped in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to start
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0), // Added more spacing
              theme_setting(context, isMobile),
              const SizedBox(height: 16.0), // Added spacing
              logoutButton(context, () => logoutUser(context)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget theme_setting(BuildContext context, bool isMobile) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light Mode'),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark Mode'),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
        ),
        
        const Divider(),
        
        Text('Color Scheme', style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile(
          title: const Text('Use Dynamic Color (Android 12+)'),
          value: themeProvider.isDynamicColor,
          onChanged: (value) {
            themeProvider.setDynamicColor(value);
          },
        ),
        
        if (!themeProvider.isDynamicColor) ...[
          const SizedBox(height: 16),
          Text('Choose a Seed Color:',
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 100, // Adjusted height to fit colors
            width: isMobile
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.25,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Adjust number of columns
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: seedColorList.length,
              itemBuilder: (context, index) {
                final color = seedColorList[index];
                final isSelected = themeProvider.selectedSeedColor == color;
                return ElevatedButton(
                  onPressed: () {
                    themeProvider.setSelectedSeedColor(color);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: isSelected
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3.0,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.onPrimaryContainer)
                      : null,
                  );
              },
            ),
          ),
        ],
      ],
  );
}
