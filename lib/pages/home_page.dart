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

    if (newRoute != _currentRoute) {
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<TimetableProvider>(context, listen: false)
            .fetchTimetable(newRoute);
        _currentRoute = newRoute;
      });
    }

    if (!_isUserDataFetched) {
      _isUserDataFetched = true;
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<UserDetails>(context, listen: false).fetchUserDetails();
      });
    }
  }

  void _showReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: Text("Route $route"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: TimetableDisplay(route: route),
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