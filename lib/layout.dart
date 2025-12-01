import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/providers/providers.dart' show UserDetails, NavigationProvider;
import 'package:nextbus/widgets/widgets.dart' show ConnectivityBanner;
import 'package:provider/provider.dart';

// Define base destinations outside the widget to avoid recreation
final List<NavigationItem> _baseDestinations = [
  NavigationItem(
      destination: NavigationDestinations.home,
      icon: Icons.home,
      label: 'Home'),
  NavigationItem(
      destination: NavigationDestinations.route,
      icon: Icons.route,
      label: 'Route'),
  NavigationItem(
      destination: NavigationDestinations.settings,
      icon: Icons.settings,
      label: 'Settings'),
];

class NavigationItem {
  final NavigationDestinations destination;
  final IconData icon;
  final String label;

  NavigationItem({
    required this.destination,
    required this.icon,
    required this.label,
  });
}

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _isInit = true; // Flag to ensure fetch only runs once

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Trigger the user details fetch only once when the widget initializes
    if (_isInit) {
      // listen: false because we don't want to rebuild THIS function, just trigger the action
      Provider.of<UserDetails>(context, listen: false).fetchUserDetails();
      _isInit = false;
    }
  }

  // Helper to generate the list dynamically based on Admin status
  List<NavigationItem> _getDestinations(bool isAdmin) {
    List<NavigationItem> destinations = List.from(_baseDestinations);

    if (isAdmin) {
      destinations.add(NavigationItem(
          destination: NavigationDestinations.admin,
          icon: Icons.admin_panel_settings,
          label: 'Admin'
      ));
    }
    return destinations;
  }

  Widget _getCurrentPage(int currentIndex, List<NavigationItem> destinations) {
    // Safety check
    if (currentIndex < 0 || currentIndex >= destinations.length) {
      return const Center(child: Text("Error: Page index out of bounds"));
    }

    final destination = destinations[currentIndex].destination;

    switch (destination) {
      case NavigationDestinations.home:
        return routesPage['home']!;
      case NavigationDestinations.route:
        return routesPage['route']!;
      case NavigationDestinations.settings:
        return routesPage['settings']!;
      case NavigationDestinations.admin:
        return routesPage["admin"]!;
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  void _onItemTapped(int index) {
    Provider.of<NavigationProvider>(context, listen: false).setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to UserDetails. If fetchUserDetails finishes, this rebuilds automatically.
    final userDetails = Provider.of<UserDetails>(context);

    // 2. Listen to NavigationProvider for tab switching
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // 3. Calculate derived state
    final int currentIndex = navigationProvider.selectedIndex;
    final List<NavigationItem> currentAppDestinations = _getDestinations(userDetails.isAdmin);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        AppLogger.info('Current Destinations Count: ${currentAppDestinations.length}');

        return Scaffold(
          body: isMobile
              ? Column(
            children: [
              // Pass the list so the helper knows which page corresponds to the index
              Expanded(child: _getCurrentPage(currentIndex, currentAppDestinations)),
              const SafeArea(
                top: false,
                child: ConnectivityBanner(),
              )
            ],
          )
              : Row(
            children: [
              _navigationRail(context, currentAppDestinations, currentIndex),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _getCurrentPage(currentIndex, currentAppDestinations)),
                    const SafeArea(
                      top: false,
                      child: ConnectivityBanner(),
                    )
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? _bottomNavigationBar(
              isMobile, context, _onItemTapped, currentAppDestinations, currentIndex)
              : null,
        );
      },
    );
  }

  Widget _navigationRail(BuildContext context, List<NavigationItem> destinations, int currentIndex) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      destinations: destinations
          .map((item) =>
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.icon,
                color: Theme.of(context).colorScheme.primary),
            label: Text(item.label),
          ))
          .toList(),
    );
  }

  BottomNavigationBar? _bottomNavigationBar(
      bool isMobile,
      BuildContext context,
      Function(int) onItemTapped,
      List<NavigationItem> destinations,
      int currentIndex) {

    // Safety check: if current index is out of bounds (e.g., waiting for Admin tab), default to 0
    final safeIndex = (currentIndex >= destinations.length) ? 0 : currentIndex;

    return BottomNavigationBar(
      items: destinations
          .map((item) =>
          BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          ))
          .toList(),
      currentIndex: safeIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}