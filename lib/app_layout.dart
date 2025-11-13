import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart' show mobileBreakpoint;
import 'package:nextbus/Providers/user_details.dart' show UserDetails;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        // AppLogger.info('Current Route: ${ModalRoute.of(context)?.settings.name}');
        AppLogger.info('Current Destinations Count: ${currentAppDestinations.length}');

        return Scaffold(
          appBar:appbar(isMobile, context,isAdmin: isAdmin, destination: currentAppDestinations),
          body: isMobile ? newRoutes[selectedIndex] : Row(
            children: [
              _navigationRail(context, currentAppDestinations),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: newRoutes[selectedIndex],),
            ],
          ),
          bottomNavigationBar: isMobile ? _bottomNavigationBar(isMobile, context,
              _onItemTapped, currentAppDestinations) : null,
          drawer: isMobile ? _buildAppDrawer(currentAppDestinations) : null,
        );
      },
    );
  }

  void _onItemTapped(int index ) {
    if (index < 0 || index >= currentAppDestinations.length) return;
    if (selectedIndex == index) return; // Avoid pushing the same route

    setState(() {
      selectedIndex = index;
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => newRoutes[index]),
    // );
  }

  Widget _buildAppDrawer(List<NavigationItem> destinations) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              'App Menu',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
          ...currentAppDestinations.asMap().entries.map((entry) {
            int idx = entry.key;
            NavigationItem item = entry.value;
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: selectedIndex == idx,
              onTap: () {
                Navigator.pop(context); // Close the drawer FIRST
                _onItemTapped(idx); // Then navigate
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _navigationRail(BuildContext context, List<NavigationItem> destinations) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: _onItemTapped, // Use the new handler
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
      onTap: onItemTapped, // Use the new handler
      type: BottomNavigationBarType.fixed,
    );
  }

}
