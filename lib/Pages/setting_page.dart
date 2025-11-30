import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/providers.dart' show ThemeProvider;
import 'package:nextbus/constant.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
      ),
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
                    onPressed: () => {LogoutUser.execute(context)},
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Determine device type based on available width
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        // 2. Define responsive sizes
        final double boxSize = isMobile ? 50.0 : 72.0;
        final double iconSize = isMobile ? 28.0 : 36.0;
        final double spacing = isMobile ? 12.0 : 20.0;

        // 3. Define responsive shape (Squircle)
        // Adjusting radius slightly for larger boxes keeps the shape consistent
        final squircleRadius = BorderRadius.circular(isMobile ? 14.0 : 18.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                spacing: spacing,
                runSpacing: spacing,
                children: seedColorList.map((color) {
                  final isSelected = themeProvider.selectedSeedColor == color;
                  return InkWell(
                    onTap: () => themeProvider.setSelectedSeedColor(color),
                    borderRadius: squircleRadius,
                    child: Container(
                      // 4. Apply dynamic sizes here
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: squircleRadius,
                        shape: BoxShape.rectangle,
                        border: isSelected
                            ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: isMobile ? 3.5 : 4.5, // Thicker border on desktop
                        )
                            : Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          size: iconSize, // Scaled icon
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
      },
    );
  }
}