import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart' show RouteProvider, NavigationProvider;
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
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      final routeProvider = Provider.of<RouteProvider>(context);

      if (routeProvider.availableRoutes.isNotEmpty) {
        if (selectedRoute == null) {
          if (routeProvider.route.isNotEmpty && routeProvider.availableRoutes.contains(routeProvider.route)) {
            selectedRoute = routeProvider.route;
          } else {
            selectedRoute = routeProvider.availableRoutes.first;
          }
          AppLogger.info("Selected route initialized to: $selectedRoute");
        }
        _isLoading = false;
      } else {
        AppLogger.warn("RouteSelect: availableRoutes is empty.");
        _isLoading = false;
      }

      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
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
            const Text("Select a route from the list below:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            // LIST VIEW
            Expanded(
              child: ListView.builder(
                itemCount: routeProvider.availableRoutes.length,
                itemBuilder: (context, index) {
                  final routeItem = routeProvider.availableRoutes[index];
                  // Determine if this specific item is the currently selected one for styling
                  final bool isSelected = selectedRoute == routeItem;

                  return ListTile(
                    title: Text("Route $routeItem"),
                    leading: Icon(
                        Icons.directions_bus,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey
                    ),
                    tileColor: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
                    onTap: () {
                      AppLogger.info("Route selected and confirmed: $routeItem");

                      // 1. Update the provider immediately
                      routeProvider.setRoute(routeItem);

                      // 2. Close the screen immediately
                      navProvider.setIndex(0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}