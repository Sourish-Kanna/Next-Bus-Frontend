import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart' show mobileBreakpoint;

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
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;

        AppLogger.log('Current Route: ${ModalRoute.of(context)?.settings.name}'); // Get current route name

        return Scaffold(
          appBar:appbar(isMobile, context, widget),
          body: isMobile ? widget.child : Row(
            children: [
              _navigationRail(context),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: widget.child,),
            ],
          ),
          bottomNavigationBar: _bottomNavigationBar(isMobile, context, widget, _onItemTapped),
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

  Widget _navigationRail(BuildContext context) {
    return NavigationRail(
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
    );
  }

  BottomNavigationBar? _bottomNavigationBar(bool isMobile, BuildContext context,
      AppLayout widget, Function(int) onItemTapped) {
    return isMobile ? BottomNavigationBar(
      items: appDestinations
          .map((item) =>
          BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          ))
          .toList(),
      currentIndex: widget.selectedIndex,
      onTap: onItemTapped, // Use the new handler
      type: BottomNavigationBarType.fixed,
    ): null;
  }

}
