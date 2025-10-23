import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/theme.dart';
import 'package:nextbus/constant.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: !isMobile
          ? AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
      )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // "Appearance" card with an expressive style
          _SettingsGroupCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              const ThemeSettings(),
            ],
          ),
          const SizedBox(height: 16),
          // "Account" card, now using your original logoutButton
          _SettingsGroupCard(
            title: 'Account',
            icon: Icons.person_outline_rounded,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: () => {logoutUser(context)},
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A reusable card with an expressive M3 style for grouping settings.
class _SettingsGroupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsGroupCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      // Expressive shape with a large corner radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                // Expressive typography for the main title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Container for all theme-related setting widgets.
class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ThemeModeSelector(),
        Divider(height: 32),
        _MaterialYouSettings(),
      ],
    );
  }
}

/// Widget for selecting the app's theme mode.
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using a more prominent text style
        Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),
        SegmentedButton<ThemeMode>(
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto_rounded),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_rounded),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_rounded),
            ),
          ],
          selected: {themeProvider.themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            themeProvider.setThemeMode(newSelection.first);
          },
        ),
      ],
    );
  }
}

/// Widget for managing Material You and color scheme settings.
class _MaterialYouSettings extends StatelessWidget {
  const _MaterialYouSettings();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using a more prominent text style
        Text('Color Scheme', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4.0),
        SwitchListTile(
          title: const Text('Use Dynamic Color'),
          subtitle: const Text('Android 12+'),
          value: themeProvider.isDynamicColor,
          onChanged: (value) {
            themeProvider.setDynamicColor(value);
          },
          secondary: const Icon(Icons.color_lens_outlined),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        if (!themeProvider.isDynamicColor) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
            child: Text(
              'Choose a Seed Color:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: seedColorList.map((color) {
              final isSelected = themeProvider.selectedSeedColor == color;
              return InkWell(
                onTap: () => themeProvider.setSelectedSeedColor(color),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  // Bolder, larger circle for a more expressive feel
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      // Thicker border for selected state
                      width: 3.5,
                    )
                        : Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
