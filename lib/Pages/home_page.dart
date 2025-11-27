import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/Providers/route_details.dart';
import 'package:nextbus/Providers/timetable_provider.dart';

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

class TimetableDisplay extends StatelessWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        if (timetableProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final timetable = timetableProvider.timetables[route];
        AppLogger.info("Timetable for route $route");
        if (timetable == null || timetable.isEmpty) {
          return const Center(child: Text('No timetable data available.'));
        }
        return ListView.builder(
          itemCount: timetable.length,
          itemBuilder: (context, index) {
            final entry = timetable[index];
            final stopName = entry['stop'];
            final timing = entry['time'];
            final delay = entry['delay'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                subtitle: Text(stopName),
                title: Text('Arrival: $timing', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('Delay: $delay'),
              ),
            );
          },
        );
      },
    );
  }
}
