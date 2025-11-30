import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/Providers/user_details.dart' show UserDetails;
import 'package:nextbus/widgets/widgets.dart' show ConnectivityBanner;
import 'package:provider/provider.dart' show Provider;

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {

  late bool isAdmin = false;
  late List<NavigationItem> currentAppDestinations = List.from(appDestinations);

  @override
  void initState() {
    super.initState();
    _fetchAdminStatus();
  }

  Future<void> _fetchAdminStatus() async {
    final userDetails = Provider.of<UserDetails>(context, listen: false);
    bool adminStatus  = false;
    try {
      adminStatus = await userDetails.isAdmin;
      AppLogger.info("Admin Status fetched: $adminStatus");
    } catch (e) {
      AppLogger.error("Error fetching admin status: $e",e);
    }

    if (mounted) {
      setState(() {
        isAdmin = adminStatus;
        _rebuildAppDestinations();
      });
    }
  }

  void _rebuildAppDestinations() {
    List<NavigationItem> updatedDestinations = List.from(appDestinations);
    if (isAdmin) {
      if (!updatedDestinations.any((dest) =>
      dest.destination == NavigationDestinations.admin)) {
        updatedDestinations.add(NavigationItem(
            destination: NavigationDestinations.admin,
            icon: Icons.admin_panel_settings,
            label: 'Admin'
        ));
      }
    }
    currentAppDestinations = updatedDestinations;
  }

  Widget _getCurrentPage() {
    // Safety check
    if (selectedIndex < 0 || selectedIndex >= currentAppDestinations.length) {
      return const Center(child: Text("Error: Page index out of bounds"));
    }

    final destination = currentAppDestinations[selectedIndex].destination;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        AppLogger.info('Current Destinations Count: ${currentAppDestinations.length}');

        return Scaffold(
          body: isMobile
              ? Column(
            children: [
              Expanded(child: _getCurrentPage()), // Use helper method
              const SafeArea(
                top: false,
                child: ConnectivityBanner(),
              )
            ],
          )
              : Row(
            children: [
              _navigationRail(context, currentAppDestinations),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _getCurrentPage()), // Use helper method
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
              isMobile, context, _onItemTapped, currentAppDestinations)
              : null,
        );
      },
    );
  }

  void _onItemTapped(int index ) {
    if (index < 0 || index >= currentAppDestinations.length) return;
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });
  }

  Widget _navigationRail(BuildContext context, List<NavigationItem> destinations) {
    return NavigationRail(
      selectedIndex: selectedIndex,
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

  BottomNavigationBar? _bottomNavigationBar(bool isMobile, BuildContext context,
      Function(int) onItemTapped, List<NavigationItem> destinations) {
    return BottomNavigationBar(
      items: destinations
          .map((item) =>
          BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          ))
          .toList(),
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}

final List<NavigationItem> appDestinations = [
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