import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nextbus/Providers/firebase_operations.dart';
import 'package:nextbus/Providers/route_details.dart';
import 'package:nextbus/Providers/time_details.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/authentication.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _changeRoute(BuildContext context, RouteProvider routeProvider) {
    String selectedRoute = routeProvider.route;
    List<String> routes = ["56", "54A", "56A"]; // Example routes

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change Route"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Select a new route:"),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRoute,
                      items: routes.map((route) {
                        return DropdownMenuItem(
                          value: route,
                          child: Text("Route $route"),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedRoute = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Confirm"),
                  onPressed: () {
                    Navigator.pop(context);
                    routeProvider.setRoute(selectedRoute);
                    CustomSnackBar.show(context, "Route changed to $selectedRoute");
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addRoute(BuildContext context, FirestoreService firestoreService, User? user) {
    if (user == null) {
      CustomSnackBar.show(context, "You must be logged in to add a route.");
      return;
    }
    TextEditingController routeController = TextEditingController();
    TextEditingController stopController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Route"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: routeController,
                  decoration: const InputDecoration(labelText: "Route Number"),
                ),
                TextField(
                  controller: stopController,
                  decoration: const InputDecoration(labelText: "Stop Name"),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: "Timing (e.g., 10:00 AM)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                firestoreService.addRoute(
                  routeController.text,
                  [stopController.text],
                  [timeController.text],
                  user.uid,
                );
                CustomSnackBar.show(context, "Added Route ${routeController.text}");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _removeRoute(BuildContext context, FirestoreService firestoreService, User? user) {
    if (user == null) {
      CustomSnackBar.show(context, "You must be logged in to remove a route.");
      return;
    }
    TextEditingController routeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Route"),
          content: TextField(
            controller: routeController,
            decoration: const InputDecoration(labelText: "Enter Route Number"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Remove"),
              onPressed: () {
                firestoreService.removeRoute(routeController.text, user.uid);
                CustomSnackBar.show(context, "Removed Route ${routeController.text}");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addBusTiming(BuildContext context, BusTimingList busTimingProvider) {
    TextEditingController routeController = TextEditingController();
    TextEditingController stopController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Bus Timing"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: routeController,
                  decoration: const InputDecoration(labelText: "Route Number"),
                ),
                TextField(
                  controller: stopController,
                  decoration: const InputDecoration(labelText: "Stop Name"),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: "Timing (e.g., 10:00 AM)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                busTimingProvider.addBusTiming(
                  routeController.text,
                  stopController.text,
                  timeController.text,
                );
                CustomSnackBar.show(context, "Added Timing for Route ${routeController.text}");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.user;
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final busTimingProvider = Provider.of<BusTimingList>(context, listen: false);
    final firestoreService = FirestoreService();
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: !isMobile
          ? AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Admin Settings"),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _SettingsGroupCard(
            title: 'Route Options',
            icon: Icons.directions_bus,
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text("Change Route"),
                onTap: () => _changeRoute(context, routeProvider),
              ),
              ListTile(
                leading: const Icon(Icons.add_road),
                title: const Text("Add Route"),
                onTap: () => _addRoute(context, firestoreService, user),
              ),
              ListTile(
                leading: const Icon(Icons.remove_road),
                title: const Text("Remove Route"),
                onTap: () => _removeRoute(context, firestoreService, user),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroupCard(
            title: 'Timings',
            icon: Icons.access_time,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("View Timings"),
                onTap: () {
                  busTimingProvider.getBusTimings(routeProvider.route);
                  CustomSnackBar.show(context, "Fetching timings for Route ${routeProvider.route}");
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_alert),
                title: const Text("Add Bus Timing"),
                onTap: () => _addBusTiming(context, busTimingProvider),
              ),
            ],
          ),
          const SizedBox(height: 16),
           _SettingsGroupCard(
            title: 'Debugging',
            icon: Icons.bug_report,
            children: [
               ListTile(
                leading: const Icon(Icons.print),
                title: const Text("Print All Variables"),
                onTap: () {
                  AppLogger.info("Route: ${routeProvider.route}");
                  AppLogger.info("User ID: ${user?.uid}");
                  AppLogger.info("Auth Status: ${user?.isAnonymous}");
                },
              ),
              ListTile(
                title: const Text("Route Selector"),
                leading: const Icon(Icons.select_all),
                onTap: () {
                  Navigator.pushNamed(context, '/route');
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(128),
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
