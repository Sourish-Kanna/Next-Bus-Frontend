import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';

class AppLayout extends StatefulWidget {
  int selectedIndex;
  final Widget child;

  AppLayout({super.key, required this.selectedIndex, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double mobileBreakpoint = 600;
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        debugPrint('Current Route: ${ModalRoute
            .of(context)
            ?.settings
            .name}'); // Get current route name

        return Scaffold(
          appBar:isMobile ?  AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            automaticallyImplyLeading: false,
            title: Text(appDestinations[widget.selectedIndex].label),
            // Label from current selected item
            leading: Builder(
              builder: (context) =>
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
          ) : null,
          body: isMobile
              ? widget.child // Display the child widget passed by the router
              : Row(
            children: [
              NavigationRail(
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: _onItemTapped, // Use the new handler
                labelType: NavigationRailLabelType.all,
                destinations: appDestinations
                    .map((item) =>
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary),
                      label: Text(item.label),
                    ))
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: widget.child, // Display the child widget
              ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
            items: appDestinations
                .map((item) =>
                BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
                .toList(),
            currentIndex: widget.selectedIndex,
            onTap: _onItemTapped, // Use the new handler
            type: BottomNavigationBarType.fixed,
          )
              : null,
          drawer: isMobile ? _buildAppDrawer() : null,
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (widget.selectedIndex == index) return; // Avoid pushing the same route

    setState(() {
      widget.selectedIndex = index;
    });
    // Navigate using named routes
    Navigator.pushNamed(
      context,
      AppRoutes.fromDestination(appDestinations[index].destination),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primaryContainer,
            ),
            child: Text(
              'App Menu',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimaryContainer),
            ),
          ),
          ...appDestinations
              .asMap()
              .entries
              .map((entry) {
            int idx = entry.key;
            NavigationItem item = entry.value;
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: widget.selectedIndex == idx,
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

}

Widget logoutButton(BuildContext context, VoidCallback logoutUser) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: ElevatedButton.icon(
      onPressed: () {logoutUser();},
      icon: Icon(
        Icons.logout,
      ),
      label: Text("Logout"),
    ),
  );
}
