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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              themeSetting(context, isMobile),
              const Divider(),
              const ExpressiveSettingsWidget(), // New widget added here
              const SizedBox(height: 16.0),
              logoutButton(context, () => logoutUser(context)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget themeSetting(BuildContext context, bool isMobile) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8.0), // Added some space for better layout

      // Replaced Radio buttons with a SegmentedButton for a modern UI
      SegmentedButton<ThemeMode>(
        segments: const <ButtonSegment<ThemeMode>>[
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            label: Text('System'),
            icon: Icon(Icons.brightness_auto),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode),
          ),
        ],
        // The 'selected' property requires a Set.
        selected: {themeProvider.themeMode},
        // The callback returns a Set of the new selection.
        onSelectionChanged: (Set<ThemeMode> newSelection) {
          // We update the theme mode with the first item in the new selection.
          themeProvider.setThemeMode(newSelection.first);
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
        const SizedBox(height: 8.0),

        // Use a Wrap layout for color selection on all screen sizes.
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: seedColorList.map((color) {
            final isSelected = themeProvider.selectedSeedColor == color;
            return InkWell(
              onTap: () => themeProvider.setSelectedSeedColor(color),
              borderRadius: BorderRadius.circular(50), // For ripple effect
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3.0,
                  )
                      : null,
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
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

// Enum for the dummy options in the new widget
enum ExpressiveOptions { optionA, optionB, optionC }

// A new widget demonstrating an "expressive" Material 3 SegmentedButton style.
class ExpressiveSettingsWidget extends StatefulWidget {
  const ExpressiveSettingsWidget({super.key});

  @override
  State<ExpressiveSettingsWidget> createState() => _ExpressiveSettingsWidgetState();
}

class _ExpressiveSettingsWidgetState extends State<ExpressiveSettingsWidget> {
  Set<ExpressiveOptions> _selection = {ExpressiveOptions.optionA};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expressive Choices', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8.0),
        SegmentedButton<ExpressiveOptions>(
          segments: const <ButtonSegment<ExpressiveOptions>>[
            ButtonSegment(
              value: ExpressiveOptions.optionA,
              label: Text('Apollo'),
              icon: Icon(Icons.rocket_launch),
            ),
            ButtonSegment(
              value: ExpressiveOptions.optionB,
              label: Text('Gemini'),
              icon: Icon(Icons.auto_awesome),
            ),
            ButtonSegment(
              value: ExpressiveOptions.optionC,
              label: Text('Artemis'),
              icon: Icon(Icons.explore),
            ),
          ],
          selected: _selection,
          onSelectionChanged: (Set<ExpressiveOptions> newSelection) {
            setState(() {
              _selection = newSelection;
            });
          },
          // Applying a custom, expressive M3 style
          style: SegmentedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
            selectedBackgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ],
    );
  }
}
