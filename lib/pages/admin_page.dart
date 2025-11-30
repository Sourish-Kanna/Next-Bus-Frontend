import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/Providers/providers.dart' show AuthService, RouteProvider, TimetableProvider;
import 'package:nextbus/common.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _changeRoute(BuildContext context, RouteProvider routeProvider) {
    String selectedRoute = routeProvider.route;
    List<String> routes = routeProvider.availableRoutes;

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

  Future<void> _addRoute(BuildContext context, TimetableProvider busTimingProvider) async {
    var aa = await busTimingProvider.addRoute("56A",["tt"],"10:00 AM", "tt","tt");
    AppLogger.onlyLocal(aa.toString());
  }

  Future<void> _updateBusTiming(BuildContext context, TimetableProvider busTimingProvider) async {
    var aa = await busTimingProvider.updateTime("56A","tt","10:00 AM");
    AppLogger.onlyLocal(aa.toString());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.user;
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final busTimingProvider = Provider.of<TimetableProvider>(context, listen: false);


    return Scaffold(
      appBar: AppBar(
              // automaticallyImplyLeading: false,
              title: const Text("Admin Settings"),
            ),
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
                onTap: () => _addRoute(context, busTimingProvider),
              ),
              // ListTile(
              //   leading: const Icon(Icons.remove_road),
              //   title: const Text("Remove Route"),
              //   onTap: () => _removeRoute(context, firestoreService, user),
              // ),
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
                onTap: () async {
                  await busTimingProvider.fetchTimetable("56A");
                  var aa = busTimingProvider.timetables["56A"];
                  AppLogger.onlyLocal(aa.toString());
                  CustomSnackBar.show(context, "Fetching timings for Route 56A}");
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_alert),
                title: const Text("Add Bus Timing"),
                onTap: () => _updateBusTiming(context, busTimingProvider),
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
                title: const Text("Show All Variables"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Debugging Info"),
                        content: SingleChildScrollView(
                          child: Text(
                            "Route: ${routeProvider.route}\n"
                            "Auth Status : ${user?.isAnonymous}\n"
                            "User Name: ${user?.displayName}\n"
                            "Available Routes: ${routeProvider.availableRoutes}",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // ListTile(
              //   title: const Text("Route Selector"),
              //   leading: const Icon(Icons.select_all),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/route');
              //   },
              // )
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
