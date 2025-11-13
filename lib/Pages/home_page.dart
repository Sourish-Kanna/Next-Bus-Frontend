import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/Pages/Helpers/home_page_helper.dart';
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

    if (newRoute != _currentRoute && newRoute != "56") {
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
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: !isMobile
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              automaticallyImplyLeading: false,
              title: Text("Route $route"),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: route == "56"
            ? LegacyTimetable(route: route)
            : TimetableDisplay(route: route),
      ),
    );
  }
}

class LegacyTimetable extends StatelessWidget {
  final String route;
  const LegacyTimetable({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NextTime(route: route),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text("Past",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    ListHome(title: "Past", isPast: true, route: route),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text("Next",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    ListHome(title: "Next", isPast: false, route: route),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
        AppLogger.info("Timetable for route $route: $timetable");
        if (timetable == null || timetable.isEmpty) {
          return const Center(child: Text('No timetable data available.'));
        }

        return ListView.builder(
          itemCount: timetable.length,
          itemBuilder: (context, index) {
            final entry = timetable[index];
            final stopName = entry['stop'];
            final timing = entry['timing'];
            final delay = entry['delay'] ?? 'No delay'; // Assuming 'delay' might be null

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                title: Text(stopName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Arrival: $timing'),
                trailing: Text(
                  'Delay: $delay',
                  style: TextStyle(
                    color: delay == 'No delay' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
