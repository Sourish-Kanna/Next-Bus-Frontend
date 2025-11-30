import 'package:flutter/material.dart';
import 'package:nextbus/widgets/widgets.dart' show TimetableDisplay;
import 'package:provider/provider.dart';
import 'package:nextbus/providers/providers.dart' show RouteProvider, TimetableProvider;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _currentRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeProvider = Provider.of<RouteProvider>(context);
    final newRoute = routeProvider.route;

    if (newRoute != _currentRoute) {
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        Provider.of<TimetableProvider>(context, listen: false)
            .fetchTimetable(newRoute);
        _currentRoute = newRoute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    String route = routeProvider.route;

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
    );
  }
}

