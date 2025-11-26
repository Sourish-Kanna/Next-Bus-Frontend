import 'package:flutter/material.dart';
import 'package:nextbus/Providers/providers.dart';
import 'package:provider/provider.dart';

class ConnectivityBanner extends StatelessWidget implements PreferredSizeWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink(); // No banner when online
        }

        return Material(
          child: Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Text('No internet connection',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 24.0); // Adjust height as needed
}
