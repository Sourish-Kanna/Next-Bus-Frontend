import 'package:flutter/material.dart';
import 'package:nextbus/widgets/widgets.dart' show SettingsGroupCard, ThemeSettings;
import 'package:nextbus/providers/providers.dart' show AuthService, UserDetails;
import 'package:provider/provider.dart';
import 'package:nextbus/pages/pages.dart' show AuthScreen;
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.commute, color: Theme.of(context).colorScheme.primary),
          title: const Text("The Story"),
          content: const SingleChildScrollView(
            child: Text(
              "This data is the result of 3.5 years of manually tracking my daily commute "
                  "from Thane Station to Tikujiniwadi.\n\n"
                  "It includes data for Route 56 and the parallel Route 156, "
                  "which shares 95% of the same path.\n\n"
                  "It started as a personal project to never miss a bus again. I hope it helps you too.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        );
      },
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
          title: const Text("Data Authenticity"),
          content: const SingleChildScrollView(
            child: Text(
              "This application uses crowdsourced data collected from user reports. "
                  "While we strive for accuracy, bus timings and availability may vary. "
                  "Please use this data as a guide.",
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    // 1. Clear local cache (Offline First logic)
    // We use context.read which is cleaner for functions
    await context.read<UserDetails>().clearUserData();
    if (!context.mounted) return;
    // 2. Sign out from Firebase
    await context.read<AuthService>().signOut();
    if (!context.mounted) return;
    // 3. Navigate to AuthScreen and REMOVE ALL BACK HISTORY
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (Route<dynamic> route) => false, // This predicate false = remove everything
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch AuthService to get the current User
    final user = context.watch<AuthService>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // --- APPEARANCE ---
          const SettingsGroupCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [ThemeSettings()],
          ),
          const SizedBox(height: 16),

          // --- ACCOUNT (With Profile) ---
          SettingsGroupCard(
            title: 'Account',
            icon: Icons.person_outline_rounded,
            children: [
              // 2. Display User Info if logged in
              if (user != null) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                      (user.displayName ?? "U")[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  title: Text(
                    user.displayName ?? "Guest User",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    user.email ?? "Signed in anonymously",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 24), // Separator
              ],

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- ABOUT ---
          SettingsGroupCard(
            title: 'About',
            icon: Icons.info_outline_rounded,
            children: [
              ListTile(
                leading: const Icon(Icons.history_edu),
                title: const Text("Why I Built This"),
                subtitle: const Text("The commuter's story"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text("Data Authenticity"),
                subtitle: const Text("Disclaimer & Sources"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDisclaimer(context),
              ),
              const Divider(height: 1, indent: 56),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  String versionText = "Loading...";
                  if (snapshot.hasData) {
                    versionText = snapshot.data!.version;
                    if (snapshot.data!.buildNumber.isNotEmpty) {
                      versionText += " (${snapshot.data!.buildNumber})";
                    }
                  }
                  return ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: const Text("Version"),
                    subtitle: Text(versionText),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}