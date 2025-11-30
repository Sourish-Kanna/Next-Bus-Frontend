import 'package:flutter/material.dart';
import 'package:nextbus/Providers/providers.dart' show RouteProvider;
import 'package:nextbus/common.dart';
import 'package:provider/provider.dart';

class RouteSelect extends StatefulWidget {
  const RouteSelect({super.key});

  @override
  State<RouteSelect> createState() => _RouteSelectState();
}

class _RouteSelectState extends State<RouteSelect> {
  String? selectedRoute;
  bool _isLoading = true;

  @override
  void initState() {
    AppLogger.info("initState called in RouteSelect");
    super.initState();
    _fetchRoutes();
    selectedRoute = Provider.of<RouteProvider>(context, listen: false).route;
  }

  Future<void> _fetchRoutes() async {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    // No need to fetch routes here if RouteProvider already loads them on initialization
    if (mounted) {
      setState(() {
        if (routeProvider.availableRoutes.isNotEmpty && (selectedRoute == null || !routeProvider.availableRoutes.contains(selectedRoute))) {
          selectedRoute = routeProvider.availableRoutes.first;
          AppLogger.info("Selected route initialized to: $selectedRoute");
        }
        _isLoading = false;
      });
    } else {
      AppLogger.warn("RouteSelect: _fetchRoutes called but widget is not mounted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info("Build method called in RouteSelect. Current selectedRoute: $selectedRoute");
    final routeProvider = Provider.of<RouteProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Route"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Choose a route:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRoute, // Ensure this is initialized or handled if null
                    items: routeProvider.availableRoutes.map((route) => DropdownMenuItem(
                      value: route,
                      child: Text("Route $route"),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRoute = value;
                        AppLogger.info("Route selected from dropdown: $selectedRoute");
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Or select from the list:"),
                  Expanded(
                    child: ListView.builder(
                      itemCount: routeProvider.availableRoutes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Route ${routeProvider.availableRoutes[index]}"),
                          leading: Icon(Icons.directions_bus, color: selectedRoute == routeProvider.availableRoutes[index] ? Colors.blue : Colors.grey),
                          onTap: () {
                            setState(() {
                              selectedRoute = routeProvider.availableRoutes[index];
                              AppLogger.info("Route selected from list: $selectedRoute");
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedRoute != null ? () {
                        if (selectedRoute != null) {
                          AppLogger.info("Confirming route: $selectedRoute");
                          routeProvider.setRoute(selectedRoute!);
                          // AppLogger.info("Route set in provider. Popping context.");
                          // Navigator.pop(context);
                        }
                      } : null,
                      child: const Text("Confirm Route"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
