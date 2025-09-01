import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nextbus/Providers/firebase_operations.dart';
import 'package:nextbus/Providers/route_details.dart';
import 'package:nextbus/Providers/time_details.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/Providers/authentication.dart';
import 'package:nextbus/Providers/user_details.dart';

void _showAdminOptionsDialog(BuildContext context, User? user) {
  final routeProvider = Provider.of<RouteProvider>(context, listen: false);
  final busTimingProvider = Provider.of<BusTimingList>(context, listen: false);
  var firestoreService = FirestoreService();

  // Function to change the route
  void changeRoute(BuildContext context, RouteProvider routeProvider) {
    String selectedRoute = routeProvider.route;
    List<String> routes = [
      "56",
      "102",
      "110",
      "205",
      "301",
      "402",
      "505",
      "606",
      "707",
      "808",
      "909",
      "1010"
    ]; // Example routes

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
                    customSnackBar(context, "Route changed to $selectedRoute");
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to add a new route
  void addRoute(BuildContext context) {
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
                  decoration: const InputDecoration(
                      labelText: "Timing (e.g., 10:00 AM)"),
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
                  user!.uid,
                );
                customSnackBar(context, "Added Route ${routeController.text}");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to remove a route
  void removeRoute(BuildContext context) {
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
                firestoreService.removeRoute(routeController.text, user!.uid);
                customSnackBar(
                    context, "Removed Route ${routeController.text}");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to add bus timing
  void addBusTiming(BuildContext context) {
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
                  decoration: const InputDecoration(
                      labelText: "Timing (e.g., 10:00 AM)"),
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
                customSnackBar(
                    context, "Added Timing for Route ${routeController.text}");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Show Admin Options Dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Admin Options"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpansionTile(
                title: const Text("Route Options"),
                leading: const Icon(Icons.directions),
                childrenPadding: const EdgeInsets.only(left: 20.0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text("Change Route"),
                    onTap: () => changeRoute(context, routeProvider),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Add Route"),
                    onTap: () => addRoute(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("Remove Route"),
                    onTap: () => removeRoute(context),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("View Timings"),
                onTap: () {
                  busTimingProvider.getBusTimings(routeProvider.route);
                  customSnackBar(context,
                      "Fetching timings for Route ${routeProvider.route}");
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Add Bus Timing"),
                onTap: () => addBusTiming(context),
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text("Print All Variables"),
                onTap: () {
                  AppLogger.log("Route: ${routeProvider.route}");
                  AppLogger.log("User ID: ${user?.uid}");
                  AppLogger.log("Auth Status: ${user?.isAnonymous}");
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

Widget adminFAB(BuildContext context, User? user) {
  bool isAdmin = true;
  // if (user != null) {
  //   isAdmin = !user.isAnonymous;
  // }
  return Visibility(
    visible: isAdmin, // Only show if the user is an admin
    child: ElevatedButton.icon(
      onPressed: () => _showAdminOptionsDialog(context, user),
      icon: const Icon(Icons.settings_suggest),
      label: const Text('Admin Options'),
    ),
  );
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.user;
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold( // Added Scaffold for proper layout
      appBar: !isMobile ? AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
      ) : null,
      body: SingleChildScrollView( // Wrapped in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to start
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              adminFAB(context, user),
              const SizedBox(height: 16.0), // Added more spacing
              testing(context),
            ],
          ),
        ),
      ),
    );
  }
}


Widget testing(BuildContext context) {
  void verify() async {
    final userDetails = Provider.of<UserDetails>(context, listen: false);

    final bool isAdmin = await userDetails.isAdmin;
    final bool isGuest = await userDetails.isGuest;
    final bool isLoggedIn = await userDetails.isLoggedIn;

    AppLogger.log("Admin: $isAdmin, guest: $isGuest, logged: $isLoggedIn");

    final timetable = Provider.of<Timetable>(context, listen: false);
    await timetable.fetchTimetable('56A');
    final timetableData = timetable.getTimetableForRoute('56A');
    for (var element in timetableData!) {
      AppLogger.log(element.toString());
    }

  }

  return ElevatedButton(
    onPressed: verify,
    child: const Text("Test API Connection"),
  );
}
