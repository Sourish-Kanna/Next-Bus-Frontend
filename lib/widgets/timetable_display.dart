import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/providers/providers.dart' show TimetableProvider;

class TimetableDisplay extends StatelessWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});

  String secTomin(num sec) {
    final duration = Duration(seconds: sec.toInt());
    // Get total minutes as a double
    double minutes = duration.inMinutes.toDouble() + (duration.inSeconds % 60) / 60.0;
    return minutes.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        // 1. Loading State
        if (timetableProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final timetable = timetableProvider.timetables[route];
        AppLogger.info("Timetable for route $route");

        // 2. Empty State (Updated to be Scrollable)
        // We wrap the text in a ListView so the RefreshIndicator in HomePage
        // can still catch the "pull down" gesture even when there is no data.
        if (timetable == null || timetable.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7, // Centers the text roughly
                child: const Center(child: Text('No timetable data available.')),
              ),
            ],
          );
        }

        // 3. Data State
        return ListView.builder(
          // CRITICAL: This ensures the list bounces and triggers refresh
          // even if there are only 1 or 2 items.
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: timetable.length,
          itemBuilder: (context, index) {
            final entry = timetable[index];
            final stopName = entry['stop'];
            final timing = entry['time'];
            final delay = "${secTomin(entry['delay'] as num)} mins";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                subtitle: Text(stopName),
                title: Text('Arrival: $timing', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('Delay: $delay'),
              ),
            );
          },
        );
      },
    );
  }
}