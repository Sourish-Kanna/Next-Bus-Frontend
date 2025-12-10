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
      // 1. Initial Load Logic
      final routeProvider = Provider.of<RouteProvider>(context);
      _resolveSelectedRoute(routeProvider);
      _isInit = false;
    }
  }

  void _resolveSelectedRoute(RouteProvider routeProvider) {
    if (routeProvider.availableRoutes.isNotEmpty) {

      // Only set if null (or you can force reset if you prefer)
      if (selectedRoute == null) {
        if (routeProvider.route.isNotEmpty && routeProvider.availableRoutes.contains(routeProvider.route)) {
          selectedRoute = routeProvider.route;
        } else {
          selectedRoute = routeProvider.availableRoutes.first;
        }
        AppLogger.info("Selected route resolved to: $selectedRoute");
      }
      _isLoading = false;
    } else {
      AppLogger.warn("RouteSelect: availableRoutes is empty.");
      _isLoading = false;
    }
  }

  // 2. REFRESH LOGIC
  Future<void> _refreshRoutes() async {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    // A. Force a re-fetch from API
    await routeProvider.fetchRoutes();

    if (!mounted) return;

    // B. Re-run the dependency logic to update UI/Selection
    setState(() {
      // Optional: Reset selectedRoute to null if you want 'refresh' to pick the default again
      // selectedRoute = null;

      _resolveSelectedRoute(routeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final routeProvider = Provider.of<RouteProvider>(context);

    AppLogger.info("Build method called. Current selectedRoute: $selectedRoute");

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

            // 3. REFRESH INDICATOR
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshRoutes,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(), // Required for pull-to-refresh on short lists
                  itemCount: routeProvider.availableRoutes.length,
                  itemBuilder: (context, index) {
                    final routeItem = routeProvider.availableRoutes[index];
                    final bool isSelected = selectedRoute == routeItem;

                    return ListTile(
                      title: Text("Route $routeItem"),
                      leading: Icon(
                        Icons.directions_bus,
                        // ✅ CHANGED: Uses Theme Scheme for both states
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      // ✅ CHANGED: Uses proper container color opacity
                      tileColor: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                          : null,
                      onTap: () {
                        AppLogger.info("Route selected and confirmed: $routeItem");
                        routeProvider.setRoute(routeItem);
                        navProvider.setIndex(0);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}