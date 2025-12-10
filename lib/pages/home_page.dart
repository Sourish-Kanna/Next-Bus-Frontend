import 'package:flutter/material.dart';
import 'package:nextbus/widgets/widgets.dart' show TimetableDisplay, ReportBusSheet;
import 'package:provider/provider.dart';
import 'package:nextbus/providers/providers.dart' show RouteProvider, TimetableProvider, UserDetails;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _currentRoute;
  bool _isUserDataFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeProvider = Provider.of<RouteProvider>(context);
    final newRoute = routeProvider.route;

    // Fetch timetable only if route changes
    if (newRoute != _currentRoute) {
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<TimetableProvider>(context, listen: false)
            .fetchTimetable(newRoute);
        _currentRoute = newRoute;
      });
    }

    // Fetch user data once
    if (!_isUserDataFetched) {
      _isUserDataFetched = true;
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<UserDetails>(context, listen: false).fetchUserDetails();
      });
    }
  }

  // 1. THE REFRESH FUNCTION
  Future<void> _refreshData() async {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    // Force a re-fetch of the timetable for the current route
    await Provider.of<TimetableProvider>(context, listen: false)
        .fetchTimetable(routeProvider.route);
  }

  void _showReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true, // <--- ADDED: Standard M3 Handle
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return const ReportBusSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    final userDetails = Provider.of<UserDetails>(context);

    String route = routeProvider.route;
    bool isGuest = userDetails.isGuest;

    return Scaffold(
        appBar: AppBar(
          // 1. Restore Color: Matches your design screenshots (Blue/Green)
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,

          automaticallyImplyLeading: false,
          centerTitle: false, // 2. Left Align: Matches Figma/M3 guidelines

          // 3. Bold Text: Matches the visual weight in your design
          title: Text(
            "Route $route",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // Optional: Add the 'Star' icon if you want to match Figma exactly
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.star_border),
          //     onPressed: () {},
          //   ),
          // ],
        ),

      // 2. WRAP BODY IN REFRESH INDICATOR
      body: RefreshIndicator(
        onRefresh: _refreshData,
        // Optional: Offset determines how far down the spinner appears
        edgeOffset: 10.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),

          child: TimetableDisplay(route: route),
        ),
      ),

      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
        onPressed: () => _showReportModal(context),
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}