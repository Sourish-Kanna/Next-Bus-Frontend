import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/common.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        // 1. Wrap in AnimatedSize for smooth slide-in/slide-out effect
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: connectivity.isOnline
              ? const SizedBox.shrink() // Height becomes 0 nicely
              : Material(
            color: Theme.of(context).colorScheme.errorContainer,
            child: InkWell(
              onTap: () async {
                // 2. Visual Feedback (Clearer)
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checking connection...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                // 3. Perform Check
                bool isNowOnline = await connectivity.checkConnection();

                // 4. Feedback
                if (context.mounted) {
                  if (isNowOnline) {
                    CustomSnackBar.show(
                      context,
                      'Back online!',
                      backgroundColor: Colors.green, // ✅ Success Color
                      foregroundColor: Colors.white,
                    );
                  } else {
                    CustomSnackBar.show(
                      context,
                      'Still offline. Please check settings.',
                      backgroundColor: Theme.of(context).colorScheme.error, // ✅ Error Color
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                // Increased padding for better touch target
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'No connection. Tap to retry.',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}