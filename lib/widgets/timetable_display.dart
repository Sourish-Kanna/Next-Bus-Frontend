import 'package:flutter/material.dart';
import 'package:nextbus/common.dart' show AppLogger;
import 'package:provider/provider.dart' show Consumer;
import 'package:nextbus/providers/providers.dart' show TimetableProvider;

class TimetableDisplay extends StatelessWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});

  String secTomin(num sec) {
    final duration = Duration(seconds: sec.toInt());
    double minutes = duration.inMinutes.toDouble() + (duration.inSeconds % 60) / 60.0;
    return minutes.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        // Loading State
        if (timetableProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(
            strokeCap: StrokeCap.round,
          ));
        }

        final timetable = timetableProvider.timetables[route];
        AppLogger.info("Timetable for route $route");

        // Empty State (Updated to be Scrollable)
        if (timetable == null || timetable.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: const Center(child: Text('No timetable data available.')),
              ),
            ],
          );
        }

        // Data State
        return ListView.builder(
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