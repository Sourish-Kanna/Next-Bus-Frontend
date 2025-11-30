import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart';
import 'package:provider/provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink(); // Takes 0 space when online
        }

        return Material(
          color: Theme.of(context).colorScheme.errorContainer,
          child: InkWell(
            onTap: () async {
              // 1. Show immediate visual feedback
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checking connection...'),
                  duration: Duration(milliseconds: 500),
                ),
              );

              // 2. Perform the actual check
              bool isNowOnline = await connectivity.checkConnection();

              // 3. Show result feedback if still mounted
              if (context.mounted) {
                if (isNowOnline) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Back online!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Still offline. Please check your settings.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No connection. Tap to retry.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.refresh,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}