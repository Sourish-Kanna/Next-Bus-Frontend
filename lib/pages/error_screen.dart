import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.title = "Failed to initialize",
    this.message = "Please try again later.",
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // This MaterialApp is separate from the main app, so we must
    // explicitly set the theme here to match the app's branding.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // ✅ Sets Light Mode button color to Deep Orange
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        // ✅ Sets Dark Mode button color to Deep Orange
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Large Error Icon (Standard Red)
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),

                // 2. Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // 3. Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                // 4. Action Button (Matches Deep Orange Seed)
                if (onRetry != null) ...[
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56, // XL Height
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        // This will now be Orange instead of Purple
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0), // Pill shape
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}