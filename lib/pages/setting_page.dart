import 'package:flutter/material.dart';
import 'package:nextbus/widgets/widgets.dart' show SettingsGroupCard, ThemeSettings;
import 'package:nextbus/Providers/providers.dart' show AuthService;
import 'package:provider/provider.dart';
import 'package:nextbus/Pages/pages.dart' show AuthScreen;


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
          SettingsGroupCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              const ThemeSettings(),
            ],
          ),
          const SizedBox(height: 16),
          // "Account" card, now using your original logoutButton
          SettingsGroupCard(
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

/// A utility class for handling user logout.
class LogoutUser {
  /// Handles signing out the user and navigating to the login screen.
  static void execute(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const AuthScreen();
    }));
  }
}
